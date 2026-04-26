//
//  AppDelegate.swift
//  Suri Firuvet
//
//  Created by XCODE on 11/04/26.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SuriFiruvet")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data error: \(error)") }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        insertarDataDePrueba()
        return true
    }

    private func insertarDataDePrueba() {
        let manager = CoreDataManager.shared
        guard manager.obtenerCitas().isEmpty else { return }

        let hoy = Date()
        let cal = Calendar.current

        let citas: [(String, Int, String, String, String)] = [
            ("Suri",     3,  "Cl\u{ED}nica Central", "Consulta General", "Revisi\u{F3}n anual de rutina"),
            ("Firulais", 7,  "Sucursal Norte",       "Vacunaci\u{F3}n",  "Vacuna antirr\u{E1}bica pendiente"),
            ("Michi",    14, "Sucursal Sur",          "Control",          "Control post-operatorio"),
            ("Rocky",   -2,  "Cl\u{ED}nica Central", "Emergencia",       "Ingiri\u{F3} objeto extra\u{F1}o"),
            ("Luna",     21, "Sucursal Norte",        "Consulta General", "Chequeo de piel y pelaje"),
        ]

        for (mascota, dias, lugar, tipo, comentario) in citas {
            let fecha = cal.date(byAdding: .day, value: dias, to: hoy) ?? hoy
            manager.insertarCita(mascota: mascota, fecha: fecha, lugar: lugar, tipo: tipo, comentario: comentario)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

