import Foundation

struct ClienteDTO: Codable {
    let id: Int?
    let nombCli: String
    let apeCli: String
    let fecNac: String?
    let uid: String?
}

struct ClienteRequest: Codable {
    let nombCli: String
    let apeCli: String
    let fecNac: String?
    let uid: String
}
