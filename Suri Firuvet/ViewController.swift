//
//  ViewController.swift
//  Suri Firuvet
//
//  Created by XCODE on 11/04/26.
//

import UIKit

class ViewController: UIViewController {

    
    
    @IBOutlet weak var txtNickUsuario: UITextField!
    
    @IBOutlet weak var txtContrasenia: UITextField!
    
    
    @IBOutlet weak var btnIngresarSistema: UIButton!
    
    @IBOutlet weak var btnRegistrarNuevaCuenta: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ocultar contraseña (detalle profesional)
                txtContrasenia.isSecureTextEntry = true
    }
    
    
    // MARK: - Acción Ingresar al Sistema
        @IBAction func ingresarSistema(_ sender: UIButton) {
            
            let nick = txtNickUsuario.text ?? ""
            let pass = txtContrasenia.text ?? ""
            
            // 1. Validar campos vacíos
            if nick.isEmpty || pass.isEmpty {
                mostrarAlerta(mensaje: "Por favor, ingresa usuario y contraseña.")
                return
            }
            
            // 2. Validación simulada (luego puedes conectar a datos reales)   Esto es bastante genérico y hay que cambiarlo después con la base de datos ya hecha
            if nick == "admin" && pass == "1234" {
                //mostrarAlerta(mensaje: "Ingreso correcto.") {
                self.irASiguientePantalla()
                }
             else {
                mostrarAlerta(mensaje: "Usuario o contraseña incorrectos.")
            }
        }
        
        // MARK: - Acción Registrar Nueva Cuenta
        @IBAction func registrarNuevaCuenta(_ sender: UIButton) {
            
            performSegue(withIdentifier: "irRegistrarCuenta", sender: nil)
            
            if let controlador = storyboard?.instantiateViewController(withIdentifier: "RegistrarCuentaController") {
                navigationController?.pushViewController(controlador, animated: true)
            }
        }
        
        // MARK: - Navegación (post login)
    func irASiguientePantalla() {
        if let controlador = storyboard?.instantiateViewController(withIdentifier: "MenuPrincipalController") {
            navigationController?.pushViewController(controlador, animated: true)
        }
    }
        
        // MARK: - Alertas reutilizables
        func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
            let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
            
            let accion = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            
            alerta.addAction(accion)
            present(alerta, animated: true)
        }


}

