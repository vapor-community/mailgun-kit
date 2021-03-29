import Foundation
import NIO
import MultipartKit

// https://github.com/vapor/vapor/blob/main/Sources/Vapor/Utilities/File.swift
extension Mailgun {
    public struct File: Encodable, Equatable {
        /// Name of the file, including extension.
        public var filename: String
        
        /// The file's data.
        public var data: ByteBuffer
        
        /// Associated content type
        public var contentType: String
        
        enum CodingKeys: String, CodingKey {
            case data, filename
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let data = self.data.getData(at: self.data.readerIndex, length: self.data.readableBytes)
            try container.encode(data, forKey: .data)
            try container.encode(filename, forKey: .filename)
        }
        
        public init(data: String, filename: String, contentType: String) {
            var buffer = ByteBufferAllocator().buffer(capacity: data.utf8.count)
            buffer.writeString(data)
            self.init(data: buffer, filename: filename, contentType: contentType)
        }
        
        public init(data: ByteBuffer, filename: String, contentType: String) {
            self.data = data
            self.filename = filename
            self.contentType = contentType
        }
    }
}

// MARK: File+Multipart
extension Mailgun.File: MultipartPartConvertible {
    public var multipart: MultipartPart? {
        var part = MultipartPart(headers: [:], body: .init(data.readableBytesView))
        part.contentType = self.contentType
        part.contentDisposition = #"form-data; filename="\#(filename)""#
        return part
    }
    
    public init?(multipart: MultipartPart) {
        fatalError("Decoding `File` as multipart is not supported with MailgunKit.")
    }
}

extension MultipartPart {
    var contentType: String? {
        get {
            self.headers.first(name: "Content-Type")
        }
        set {
            if let value = newValue {
                self.headers.replaceOrAdd(name: "Content-Type", value: value)
            } else {
                self.headers.remove(name: "Content-Type")
            }
        }
    }
    
    var contentDisposition: String? {
        get {
            self.headers.first(name: "Content-Disposition")
        }
        set {
            if let newValue = newValue {
                self.headers.replaceOrAdd(name: "Content-Disposition", value: newValue)
            } else {
                self.headers.remove(name: "Content-Disposition")
            }
        }
    }
}
