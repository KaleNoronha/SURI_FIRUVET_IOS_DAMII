//
//  RegistrarCuentaController.swift
//  Suri Firuvet
//
//  Created by XCODE on 18/04/26.
//

import UIKit

class RegistrarCuentaController: UIViewController {

    
    
    @IBOutlet weak var txtNombreCompleto: UITextField!
    
    @IBOutlet weak var txtFechaNacimiento: UITextField!
    
    @IBOutlet weak var txtNickUsuario: UITextField!
    
    @IBOutlet weak var txtContrasenia: UITextField!
    
    @IBOutlet weak var txtRepetirContrasenia: UITextField!
    
    @IBOutlet weak var opAceptarTeryCon: UISwitch!
    
    @IBOutlet weak var btnCrearCuenta: UIButton!
    
    @IBOutlet weak var btnVolverIniciarSesion: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Acción Crear Cuenta
        @IBAction func crearCuenta(_ sender: UIButton) {
            
            // Obtener valores (con nil-coalescing para evitar errores)
            let nombre = txtNombreCompleto.text ?? ""
            let fecha = txtFechaNacimiento.text ?? ""
            let nick = txtNickUsuario.text ?? ""
            let pass = txtContrasenia.text ?? ""
            let repetirPass = txtRepetirContrasenia.text ?? ""
            
            // 1. Validar campos vacíos
            if nombre.isEmpty || fecha.isEmpty || nick.isEmpty || pass.isEmpty || repetirPass.isEmpty {
                mostrarAlerta(mensaje: "Por favor, completa todos los campos.")
                return
            }
            
            // 2. Validar contraseñas
            if pass != repetirPass {
                mostrarAlerta(mensaje: "Las contraseñas no coinciden.")
                return
            }
            
            // 3. Validar switch
            if !opAceptarTeryCon.isOn {
                mostrarAlerta(mensaje: "Debes aceptar los términos y condiciones.")
                return
            }
            
            // 4. Registro exitoso (simulado)
            mostrarAlerta(mensaje: "Cuenta creada correctamente.") {
                self.irAPantallaLogin()
            }
        }
        
        // MARK: - Acción Volver a Iniciar Sesión
        @IBAction func volverIniciarSesion(_ sender: UIButton) {
            irAPantallaLogin()
        }
        
        // MARK: - Navegación
        func irAPantallaLogin() {
            dismiss(animated: true)
            
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
