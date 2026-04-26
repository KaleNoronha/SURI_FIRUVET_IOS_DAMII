import Foundation

class CitaService {
    static let shared = CitaService()

    // Cambia esta URL por la de tu API
    private let baseURL = "https://tu-api.com/api/citas"

    func obtenerCitas(completion: @escaping (Result<[CitaDTO], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "URL inválida", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Si tu API requiere token: request.setValue("Bearer <token>", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Sin datos", code: 0)))
                return
            }
            do {
                let citas = try JSONDecoder().decode([CitaDTO].self, from: data)
                completion(.success(citas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
