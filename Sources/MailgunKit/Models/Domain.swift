import Foundation

extension Mailgun {
    public struct Domain {
        public let domain: String
        public let region: Region
        
        public init(_ domain: String, _ region: Region) {
            self.domain = domain
            self.region = region
        }
    }
}
