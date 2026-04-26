//
//  CoreDataManager.swift
//  Suri Firuvet
//
//  Created by XCODE on 25/04/26.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Insertar nueva cita
    func insertarCita(mascota: String, fecha: Date, lugar: String, tipo: String, comentario: String) {
        let cita = CitaEntity(context: context)
        cita.mascota = mascota
        cita.fechaHora = fecha
        cita.lugar = lugar
        cita.tipo = tipo
        cita.comentario = comentario
        
        do {
            try context.save()
            print("Cita guardada correctamente")
        } catch {
            print("Error al guardar cita: \(error.localizedDescription)")
        }
    }
    
    // Obtener todas las citas
    func obtenerCitas() -> [CitaEntity] {
        let request: NSFetchRequest<CitaEntity> = CitaEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error al obtener citas: \(error.localizedDescription)")
            return []
        }
    }
    
    // Eliminar una cita
    func eliminarCita(_ cita: CitaEntity) {
        context.delete(cita)
        do {
            try context.save()
            print("Cita eliminada correctamente")
        } catch {
            print("Error al eliminar cita: \(error.localizedDescription)")
        }
    }
}

