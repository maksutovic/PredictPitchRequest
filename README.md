# Usage
```swift
    func uploadAudioFile() async throws -> MidiResponse {
        guard let url = /* Your audio file */
         else {
            // The file wasn’t found in the bundle.
            throw NSError(domain: "com.yourapp.error",
                                code: 1001,
                                userInfo: [NSLocalizedDescriptionKey: "Cannot find audioFileURL"])
        }
        let endpoint = /* Your endpoint */
        let request = try AudioFileUploadRequest(fileUrl: url, endpoint: endpoint)

        // Use URLSession to send the request
        let (responseData, _) = try await URLSession.shared.upload(for: request.urlRequest, from: request.body)

        let midiResponse = try JSONDecoder().decode(MidiResponse.self, from: responseData)
        return midiResponse
    }
```
