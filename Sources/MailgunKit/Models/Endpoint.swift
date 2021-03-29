import Foundation
import NIO
import NIOHTTP1
import MultipartKit

extension Mailgun {
    public struct Endpoint {
        enum Body {
            case encodable(MailgunRequestBodyEncodable)
        }
        
        let path: String
        let body: Body?
        let method: HTTPMethod
        
        init(path: String, body: Body? = nil, method: HTTPMethod) {
            self.path = path
            self.body = body
            self.method = method
        }
    }
}

// MARK: Default endpoints
public extension Mailgun.Endpoint {
    static func send(_ message: Mailgun.Message) -> Mailgun.Endpoint {
        .init(path: "messages", body: .encodable(message), method: .POST)
    }
    
    static func send(_ template: Mailgun.TemplateMessage) -> Mailgun.Endpoint {
        .init(path: "messages", body: .encodable(template), method: .POST)
    }
    
    static func createTemplate(_ template: Mailgun.Template) -> Mailgun.Endpoint {
        .init(path: "templates", body: .encodable(template), method: .POST)
    }
}
