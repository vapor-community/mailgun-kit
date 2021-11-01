import Foundation
import NIOCore
import NIOFoundationCompat
import AsyncHTTPClient
import MultipartKit
import Logging

public struct LiveMailgunClient: MailgunClient {
    public let eventLoop: EventLoop
    public let config: Mailgun.Configuration
    public let httpClient: HTTPClient
    public let domain: Mailgun.Domain
    public let logger: Logger
    
    /// Initialize with default domain
    public init(
        config: Mailgun.Configuration,
        eventLoop: EventLoop,
        httpClient: HTTPClient,
        logger: Logger
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.httpClient = httpClient
        self.domain = config.defaultDomain
        self.logger = logger
    }
    
    /// Initialize with custom domain
    public init(
        config: Mailgun.Configuration,
        eventLoop: EventLoop,
        httpClient: HTTPClient,
        logger: Logger,
        domain: Mailgun.Domain
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.httpClient = httpClient
        self.logger = logger
        self.domain = domain
    }
    
    public func sendRequest(_ endpoint: Mailgun.Endpoint) -> EventLoopFuture<HTTPClient.Response> {
        do {
            guard let authData = "api:\(config.apiKey)".data(using: .utf8)?.base64EncodedString() else {
                throw MailgunError.encodingProblem
            }
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "Basic \(authData)")
            
            var body = ByteBufferAllocator().buffer(capacity: 0)
            
            switch endpoint.body {
            case let .encodable(encodable):
                try encodable.encode(to: &body, headers: &headers)
            case .none:
                break
            }
            
            let url = "\(baseURL)/\(domain.domain)/\(endpoint.path)"
            let request = try HTTPClient.Request(
                url: url,
                method: endpoint.method,
                headers: headers,
                body: .byteBuffer(body)
            )
            
            return httpClient
                .execute(request: request, eventLoop: .delegate(on: eventLoop))
                .flatMapThrowing { response in
                    guard (200...299).contains(response.status.code) else {
                        guard response.status != .unauthorized else {
                            throw MailgunError.authenticationFailed
                        }
                        
                        guard
                            let responseBody = response.body,
                            let errorResponse = try? JSONDecoder().decode(Mailgun.ErrorResponse.self, from: responseBody)
                        else {
                            throw MailgunError.unknownError(response)
                        }
                        
                        if errorResponse.message.hasPrefix("template") {
                            throw MailgunError.unableToCreateTemplate(errorResponse)
                        } else {
                            throw MailgunError.unableToSendEmail(errorResponse)
                        }
                    }
                    
                    return response
                }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    public func delegating(to eventLoop: EventLoop) -> LiveMailgunClient {
        LiveMailgunClient(config: self.config, eventLoop: eventLoop, httpClient: self.httpClient, logger: self.logger, domain: self.domain)
    }
    
    /// Base API URL based on the current region
    private var baseURL: String {
        switch domain.region {
        case .us: return "https://api.mailgun.net/v3"
        case .eu: return "https://api.eu.mailgun.net/v3"
        }
    }
}
