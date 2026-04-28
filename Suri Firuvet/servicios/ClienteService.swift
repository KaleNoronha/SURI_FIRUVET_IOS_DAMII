import Foundation

class ClienteService {
    static let shared = ClienteService()

    private let baseURL = "https://suri-firuvet-ios-damii-api.onrender.com/api/clientes"

    // MARK: - Buscar cliente por uid de Firebase
    func buscarPorUid(_ uid: String, completion: @escaping (Result<ClienteDTO?, Error>) -> Void) {
        request(url: "\(baseURL)/uid/\(uid)", method: "GET") { data, error in
            if let error = error { 
                print("[API] buscarPorUid error: \(error.localizedDescription)")
                completion(.failure(error))
                return 
            }
            guard let data = data else { 
                print("[API] buscarPorUid: cliente no encontrado (404)")
                completion(.success(nil))
                return 
            }
            do {
                let cliente = try JSONDecoder().decode(ClienteDTO.self, from: data)
                print("[API] buscarPorUid: cliente encontrado id=\(String(describing: cliente.id))")
                completion(.success(cliente))
            } catch {
                print("[API] buscarPorUid decode error: \(error)")
                completion(.success(nil))
            }
        }
    }

    // MARK: - Crear cliente
    func crearCliente(_ cliente: ClienteRequest, completion: @escaping (Result<ClienteDTO, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(cliente) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error al codificar datos"])))
            return
        }
        print("[API] crearCliente uid=\(cliente.uid) nombre=\(cliente.nombCli)")
        print("[API] crearCliente body=\(String(data: body, encoding: .utf8) ?? "-")")
        request(url: baseURL, method: "POST", body: body) { data, error in
            if let error = error { 
                print("[API] crearCliente error: \(error.localizedDescription)")
                completion(.failure(error))
                return 
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sin datos"])))
                return
            }
            do {
                let clienteCreado = try JSONDecoder().decode(ClienteDTO.self, from: data)
                print("[API] crearCliente exitoso id=\(String(describing: clienteCreado.id))")
                completion(.success(clienteCreado))
            } catch {
                print("[API] crearCliente decode error: \(error)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Buscar o crear cliente (flujo completo post-login)
    func sincronizarCliente(uid: String, nombre: String, apellido: String, completion: @escaping (Result<Int, Error>) -> Void) {
        buscarPorUid(uid) { result in
            switch result {
            case .success(let cliente):
                if let cliente = cliente, let id = cliente.id {
                    // Ya existe, retorna su id
                    completion(.success(id))
                } else {
                    // No existe, lo crea
                    let req = ClienteRequest(nombCli: nombre, apeCli: apellido, fecNac: nil, uid: uid)
                    self.crearCliente(req) { createResult in
                        switch createResult {
                        case .success(let nuevo): completion(.success(nuevo.id ?? 0))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
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

        URLSession.shared.dataTask(with: req) { data, response, error in
            if let http = response as? HTTPURLResponse {
                print("[API] \(method) \(url) → HTTP \(http.statusCode)")
            }
            if let http = response as? HTTPURLResponse, http.statusCode == 404 {
                completion(nil, nil)
                return
            }
            completion(data, error)
        }.resume()
    }
}
