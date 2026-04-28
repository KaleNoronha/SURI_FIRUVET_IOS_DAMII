import Foundation

class ClinicaService {
    static let shared = ClinicaService()

    private let baseURL = "https://suri-firuvet-ios-damii-api.onrender.com/api/clinicas"

    func listarClinicas(completion: @escaping (Result<[ClinicaDTO], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.success([])); return }
            do {
                let clinicas = try JSONDecoder().decode([ClinicaDTO].self, from: data)
                completion(.success(clinicas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
