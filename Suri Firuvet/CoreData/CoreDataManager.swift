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
        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        container.loadPersistentStores { desc, error in
            guard let error = error as NSError? else { return }
            // Si el store es incompatible, lo destruye y recrea vacío
            if let url = desc.url {
                try? NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
                    .destroyPersistentStore(at: url, ofType: desc.type)
            }
            container.loadPersistentStores { _, _ in }
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
        let context = persistentContainer.viewContext
        let fetch: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "uid == %@", uid)
        let existentes = (try? context.fetch(fetch)) ?? []
        existentes.forEach { context.delete($0) }

        for m in mascotas {
            agregarEntidad(m, uid: uid)
        }
        saveContext()
    }

    func agregarMascotaLocal(_ mascota: MascotaDTO, uid: String) {
        agregarEntidad(mascota, uid: uid)
        saveContext()
    }

    private func agregarEntidad(_ m: MascotaDTO, uid: String) {
        let entity = MascotaEntity(context: context)
        entity.idRemoto = Int32(m.id ?? 0)
        entity.nombre   = m.nombMas
        entity.tipo     = m.nombreTipo
        entity.apodos   = m.apodos
        entity.alergias = m.alergias
        entity.uid      = uid
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

