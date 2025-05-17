import SwiftUI

struct ContentView: View {
    @State private var responseText = "Response will appear here"
    @State private var isLoading = false
    @State private var name = ""
    @State private var age = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Simple API Demo")
                .font(.title)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    isLoading = true
                    fetchData()
                }) {
                    Text("GET Data")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                
                Button(action: {
                    isLoading = true
                    postData()
                }) {
                    Text("POST Data")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            
            // Input fields for POST data
            VStack(alignment: .leading, spacing: 10) {
                Text("POST Request Data:")
                    .font(.headline)
                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
//                TextField("Age", text: $age)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    #if os(iOS)
//                    .keyboardType(.numberPad)
//                    #endif
//                    .disabled(isLoading)
            }
            .padding()
            
            if isLoading {
                ProgressView()
            }
            
            ScrollView {
                Text(responseText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 300)
            .border(Color.gray, width: 1)
            .padding()
        }
        .padding()
    }
    
    func fetchData() {
        APIService.fetchData { result in
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.responseText = formatJSON(response)
                case .failure(let error):
                    self.responseText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func postData() {
        // Create payload dictionary
        var payload: [String: Any] = [:]
        payload["content"] = name
        
        // Only add age if it's a valid number
//        if let ageValue = Int(age) {
//            payload["age"] = ageValue
//        }
        
        // Add any other data you want to send
//        payload["timestamp"] = Date().timeIntervalSince1970
        
        // Make the POST request
        APIService.postData(endpoint: "/api/ai/ping", payload: payload) { result in
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.responseText = formatJSON(response)
                case .failure(let error):
                    self.responseText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func formatJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}

#Preview {
    ContentView()
}
