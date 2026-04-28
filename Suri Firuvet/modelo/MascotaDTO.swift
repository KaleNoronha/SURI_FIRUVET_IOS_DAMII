import Foundation

struct MascotaDTO: Codable {
    let id: Int
    let nombMas: String
    let tipoMas: Int
    let idCliente: Int
    let nombreTipo: String?
}
