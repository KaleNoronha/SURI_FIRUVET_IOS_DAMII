import Foundation

struct MascotaDTO: Codable {
    let id: Int?
    let nombMas: String?
    let idTipoMascota: Int?
    let nombreTipo: String?
    let idCliente: Int?
    let apodos: String?
    let alergias: String?
}

struct MascotaRequest: Codable {
    let uid: String
    let nombMas: String
    let idTipoMascota: Int
    let apodos: String?
    let alergias: String?
}
