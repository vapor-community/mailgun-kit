import Foundation

extension Mailgun {
    public struct Configuration {
        public let apiKey: String
        public let defaultDomain: Domain
        
        /// Initializer
        ///
        /// - Parameters:
        ///   - apiKey: API key including "key-" prefix
        ///   - defaultDomain: Default domain
        public init(apiKey: String, defaultDomain: Domain) {
            self.apiKey = apiKey
            self.defaultDomain = defaultDomain
        }
    }
}
