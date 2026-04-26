//
//  CoreDataManager.swift
//  Suri Firuvet
//
//  Created by XCODE on 25/04/26.
//

import CoreData
import UIKit
import FirebaseFirestore

class CoreDataManager {
    static let shared = CoreDataManager()
    private let db = Firestore.firestore()
    
    // Insertar nueva cita
    func insertarCita(uid: String, mascota: String, fecha: Date, lugar: String, tipo: String, comentario: String) {
        let datos: [String: Any] = [
            "mascota": mascota,
            "fechaHora": Timestamp(date: fecha),
            "lugar": lugar,
            "tipo": tipo,
            "comentario": comentario
        ]
        db.collection("usuarios").document(uid).collection("citas").addDocument(data: datos) { error in
            if let error {
                print("Error al guardar cita: \(error.localizedDescription)")
            } else {
                print("Cita guardada correctamente")
            }
        }
    }
    
    // Obtener todas las citas
    func obtenerCitas(uid: String, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection("usuarios").document(uid).collection("citas").getDocuments { snapshot, error in
            if let error {
                print("Error al obtener citas: \(error.localizedDescription)")
                completion([])
                return
            }
            completion(snapshot?.documents ?? [])
        }
    }
    
    // Eliminar una cita
    func eliminarCita(uid: String, citaId: String) {
        db.collection("usuarios").document(uid).collection("citas").document(citaId).delete { error in
            if let error {
                print("Error al eliminar cita: \(error.localizedDescription)")
            } else {
                print("Cita eliminada correctamente")
            }
        }
    }
}

