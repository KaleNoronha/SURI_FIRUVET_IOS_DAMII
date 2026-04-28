import Foundation

struct CitaDTO: Codable {
    let idCita: Int?
    let nombreTipoCita: String?
    let fecha: String?
    let comentario: String?
    let idMascota: Int?
    let nombreMascota: String?
    let idCliente: Int?
    let nombreCliente: String?
    let idClinica: Int?
    let nombreClinica: String?
}

struct CrearCitaRequest: Codable {
    let uid: String
    let idTipoCita: Int
    let fecha: String
    let comentario: String?
    let idMascota: Int
    let idClinica: Int
}
