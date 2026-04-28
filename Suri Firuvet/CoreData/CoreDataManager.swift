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

    // MARK: - Core Data Stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SuriFiruvet")
        container.loadPersistentStores { _, error in
            if let error { print("CoreData error: \(error)") }
        }
        return container
    }()

    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    private func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
    }
    
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

    // MARK: - Mascotas (Core Data local)
    func guardarMascotas(_ mascotas: [MascotaDTO], uid: String) {
        // Borra las anteriores del mismo uid
        let fetch: NSFetchRequest<NSFetchRequestResult> = MascotaEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "uid == %@", uid)
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try? context.execute(delete)

        for m in mascotas {
            let entity = MascotaEntity(context: context)
            entity.idRemoto  = Int32(m.id ?? 0)
            entity.nombre    = m.nombMas
            entity.tipo      = m.nombreTipo
            entity.apodos    = m.apodos
            entity.alergias  = m.alergias
            entity.uid       = uid
        }
        saveContext()
    }

    func obtenerMascotasLocales(uid: String) -> [MascotaEntity] {
        let fetch: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "uid == %@", uid)
        return (try? context.fetch(fetch)) ?? []
    }

    func eliminarMascotaLocal(idRemoto: Int32) {
        let fetch: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "idRemoto == %d", idRemoto)
        if let entity = try? context.fetch(fetch).first {
            context.delete(entity)
            saveContext()
        }
    }

    func actualizarMascotaLocal(idRemoto: Int32, nombre: String?, apodos: String?, alergias: String?) {
        let fetch: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "idRemoto == %d", idRemoto)
        if let entity = try? context.fetch(fetch).first {
            entity.nombre   = nombre
            entity.apodos   = apodos
            entity.alergias = alergias
            saveContext()
        }
    }
}

