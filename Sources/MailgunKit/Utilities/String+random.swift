import Foundation

extension String {
    static func random(length: Int) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        
        var string = ""
        for _ in 0..<length {
            string.append(chars.randomElement()!)
        }
        return string
    }
}
