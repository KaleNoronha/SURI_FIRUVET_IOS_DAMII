import Foundation

class CitaService {
    static let shared = CitaService()

    // TODO: Cambia esta URL por la de tu API real
    private let baseURL = "https://suri-firuvet-ios-damii-api.onrender.com/api/citas"

    // MARK: - Listar todas las citas
    func listarCitas(uid: String, completion: @escaping (Result<[CitaDTO], Error>) -> Void) {
        request(url: "\(baseURL)?uid=\(uid)", method: "GET") { data, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.success([])); return }
            do {
                let citas = try JSONDecoder().decode([CitaDTO].self, from: data)
                completion(.success(citas))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Crear cita
    func crearCita(_ cita: CrearCitaRequest, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(cita) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error al codificar datos"])))
            return
        }
        request(url: baseURL, method: "POST", body: body) { data, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sin datos"])))
                return
            }
            do {
                let citaCreada = try JSONDecoder().decode(CitaDTO.self, from: data)
                completion(.success(citaCreada))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Detalle de cita
    func detalleCita(id: Int, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        request(url: "\(baseURL)/\(id)", method: "GET") { data, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sin datos"])))
                return
            }
            do {
                let cita = try JSONDecoder().decode(CitaDTO.self, from: data)
                completion(.success(cita))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Modificar cita
    func modificarCita(id: Int, _ cita: CrearCitaRequest, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(cita) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error al codificar datos"])))
            return
        }
        request(url: "\(baseURL)/\(id)", method: "PUT", body: body) { data, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sin datos"])))
                return
            }
            do {
                let citaActualizada = try JSONDecoder().decode(CitaDTO.self, from: data)
                completion(.success(citaActualizada))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Eliminar cita
    func eliminarCita(id: Int, uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        request(url: "\(baseURL)/\(id)?uid=\(uid)", method: "DELETE") { _, error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // MARK: - Request genérico
    private func request(url: String, method: String, body: Data? = nil, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL inválida"]))
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        URLSession.shared.dataTask(with: req) { data, _, error in
            completion(data, error)
        }.resume()
    }
}
