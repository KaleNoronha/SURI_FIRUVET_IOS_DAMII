import Foundation

class TipoCitaService {
    static let shared = TipoCitaService()

    private let baseURL = "https://suri-firuvet-ios-damii-api.onrender.com/api/tipos-cita"

    func listarTipos(completion: @escaping (Result<[TipoCitaDTO], Error>) -> Void) {
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
                let tipos = try JSONDecoder().decode([TipoCitaDTO].self, from: data)
                completion(.success(tipos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
