import Foundation

extension Array where Element == Mailgun.FullEmail {
    var formatted: [String] {
        map { entry in
            guard let name = entry.name else {
                return entry.email
            }
            return "\(name) <\(entry.email)>"
        }
    }
}
