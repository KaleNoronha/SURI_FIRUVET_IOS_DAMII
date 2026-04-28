import Foundation

struct MascotaDTO: Codable {
    let id: Int?
    let nombMas: String?
    let idTipoMascota: Int?
    let nombreTipo: String?
    let idCliente: Int?
}

struct MascotaRequest: Codable {
    let uid: String
    let nombMas: String
    let idTipoMascota: Int
}
