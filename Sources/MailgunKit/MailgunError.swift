import Foundation
import AsyncHTTPClient

public enum MailgunError: Error {
    /// Encoding problem
    case encodingProblem
    
    /// Failed authentication
    case authenticationFailed
    
    /// Failed to send email (with error message)
    case unableToSendEmail(Mailgun.ErrorResponse)
    
    /// Failed to create template (with error message)
    case unableToCreateTemplate(Mailgun.ErrorResponse)
    
    /// Generic error
    case unknownError(HTTPClient.Response)
    
    /// Identifier
    public var identifier: String {
        switch self {
        case .encodingProblem:
            return "mailgun.encoding_error"
        case .authenticationFailed:
            return "mailgun.auth_failed"
        case .unableToSendEmail:
            return "mailgun.send_email_failed"
        case .unableToCreateTemplate:
            return "mailgun.create_template_failed"
        case .unknownError:
            return "mailgun.unknown_error"
        }
    }
    
    /// Reason
    public var reason: String {
        switch self {
        case .encodingProblem:
            return "Encoding problem"
        case .authenticationFailed:
            return "Failed authentication"
        case .unableToSendEmail(let err):
            return "Failed to send email (\(err.message))"
        case .unableToCreateTemplate(let err):
            return "Failed to create template (\(err.message))"
        case .unknownError:
            return "Generic error"
        }
    }
}

