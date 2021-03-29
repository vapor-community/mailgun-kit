import NIO
import AsyncHTTPClient

public protocol MailgunClient {
    func sendRequest(_ endpoint: Mailgun.Endpoint) -> EventLoopFuture<HTTPClient.Response>
    func delegating(to eventLoop: EventLoop) -> Self
}
