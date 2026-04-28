import Foundation

class MascotaService {
    static let shared = MascotaService()

    private let baseURL = "https://suri-firuvet-ios-damii-api.onrender.com/api/mascotas"

    func listarMascotas(uid: String, completion: @escaping (Result<[MascotaDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?uid=\(uid)") else {
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
                let mascotas = try JSONDecoder().decode([MascotaDTO].self, from: data)
                completion(.success(mascotas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
