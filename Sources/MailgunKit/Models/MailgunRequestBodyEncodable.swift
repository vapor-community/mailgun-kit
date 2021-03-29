import Foundation
import NIO
import MultipartKit

enum MailgunBodyContentType {
    case formData
}

protocol MailgunRequestBodyEncodable: Encodable {
    static var contentType: MailgunBodyContentType { get }
}

extension MailgunRequestBodyEncodable {
    func encode(to buffer: inout ByteBuffer, headers: inout HTTPHeaders) throws {
        switch Self.contentType {
        case .formData:
            let boundary = "---mailgunBoundary\(String.random(length: 16))"
            try FormDataEncoder().encode(self, boundary: boundary, into: &buffer)
            headers.replaceOrAdd(name: "Content-Type", value: "multipart/form-data;boundary=\(boundary)")
        }
    }
}
