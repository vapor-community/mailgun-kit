import Foundation

extension Mailgun {
    /// Error response object
    public struct ErrorResponse: Decodable {
        /// Error messsage
        public let message: String
    }

}
