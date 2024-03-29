import Foundation

public struct MidiResponse: Codable {
    public let notes: [PredictNote]
}

// Represents each note in the JSON response
public struct PredictNote: Codable {
    public let pitch: Int
    public let start: Double
    public let end: Double
    public let velocity: Int
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol URLRequestProtocol {
    var url: URL { get }
    var body: Data { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var urlRequest: URLRequest { get }
}

extension URLRequestProtocol {
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

public enum AudioFileUploadError: Error {
    case invalidFileURL
    case fileDataReadError
}

public struct AudioFileUploadRequest: URLRequestProtocol {
    public var url: URL
    public var body: Data
    public var method: HTTPMethod
    public var headers: [String: String]?
    private static let boundary: String = "Boundary-\(UUID().uuidString)"

    public init(fileUrl: URL, endpoint: String) throws {
        guard let endpointURL = URL(string: endpoint) else {
            throw AudioFileUploadError.invalidFileURL
        }
        self.url = endpointURL
        self.method = .post
        self.headers = ["Content-Type": "multipart/form-data; boundary=\(AudioFileUploadRequest.boundary)"]

        do {
            self.body = try AudioFileUploadRequest.createRequestBody(fileUrl: fileUrl)
        } catch {
            throw AudioFileUploadError.fileDataReadError
        }
    }

    private static func createRequestBody(fileUrl: URL) throws -> Data {
        var data = Data()
        
        // Read file data
        let fileData = try Data(contentsOf: fileUrl)
        
        // Add the audio file to the request body
        data.append("--\(AudioFileUploadRequest.boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileUrl.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        
        // Append the read file data
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        
        // End of the request body
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return data
    }
}
