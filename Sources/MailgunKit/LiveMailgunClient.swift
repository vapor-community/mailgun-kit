import Foundation
import NIO
import AsyncHTTPClient
import MultipartKit

public struct LiveMailgunClient: MailgunClient {
    private let eventLoop: EventLoop
    private let config: Mailgun.Configuration
    private let httpClient: HTTPClient
    private let domain: Mailgun.Domain
    
    /// Initialize with default domain
    public init(
        config: Mailgun.Configuration,
        eventLoop: EventLoop,
        httpClient: HTTPClient
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.httpClient = httpClient
        self.domain = config.defaultDomain
    }
    
    /// Initialize with custom domain
    public init(
        config: Mailgun.Configuration,
        eventLoop: EventLoop,
        httpClient: HTTPClient,
        domain: Mailgun.Domain
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.httpClient = httpClient
        self.domain = domain
    }
    
    public func send(_ endpoint: Mailgun.Endpoint) -> EventLoopFuture<HTTPClient.Response> {
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
                        
                        guard let body = response.body,
                              let errorResponse = try? JSONDecoder().decode(Mailgun.ErrorResponse.self, from: body)
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
        LiveMailgunClient(config: self.config, eventLoop: eventLoop, httpClient: self.httpClient, domain: self.domain)
    }
    
    /// Base API URL based on the current region
    private var baseURL: String {
        switch domain.region {
        case .us: return "https://api.mailgun.net/v3"
        case .eu: return "https://api.eu.mailgun.net/v3"
        }
    }
}
