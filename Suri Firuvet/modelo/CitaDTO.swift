import Foundation

struct CitaDTO: Codable {
    let id: Int?
    let mascota: String?
    let fechaHora: String?
    let lugar: String?
    let tipo: String?
    let comentario: String?

    enum CodingKeys: String, CodingKey {
        case id
        case mascota
        case fechaHora = "fecha_hora"
        case lugar
        case tipo
        case comentario
    }
}
