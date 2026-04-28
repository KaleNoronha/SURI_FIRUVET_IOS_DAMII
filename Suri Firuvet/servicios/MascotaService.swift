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

    // MARK: - Crear mascota
    func crearMascota(_ mascota: MascotaRequest, completion: @escaping (Result<MascotaDTO, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(mascota) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error al codificar datos"])))
            return
        }
        guard let url = URL(string: baseURL) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sin datos"])))
                return
            }
            do {
                let nueva = try JSONDecoder().decode(MascotaDTO.self, from: data)
                completion(.success(nueva))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
