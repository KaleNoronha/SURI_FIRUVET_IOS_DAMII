//
//  RegistrarCuentaController.swift
//  Suri Firuvet
//
//  Created by XCODE on 18/04/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrarCuentaController: UIViewController {

    @IBOutlet weak var txtNombreCompleto: UITextField!
    @IBOutlet weak var txtFechaNacimiento: UITextField!
    @IBOutlet weak var txtCorreoUsuario: UITextField!
    @IBOutlet weak var txtContrasenia: UITextField!
    @IBOutlet weak var txtRepetirContrasenia: UITextField!
    @IBOutlet weak var opAceptarTeryCon: UISwitch!
    @IBOutlet weak var btnCrearCuenta: UIButton!
    @IBOutlet weak var btnVolverIniciarSesion: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtContrasenia.isSecureTextEntry = true
        txtRepetirContrasenia.isSecureTextEntry = true
    }

    @IBAction func crearCuenta(_ sender: UIButton) {
        let nombre = txtNombreCompleto.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let fecha = txtFechaNacimiento.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let email = txtCorreoUsuario.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pass = txtContrasenia.text ?? ""
        let repetirPass = txtRepetirContrasenia.text ?? ""

        guard !nombre.isEmpty, !fecha.isEmpty, !email.isEmpty, !pass.isEmpty, !repetirPass.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, completa todos los campos.")
            return
        }
        guard pass == repetirPass else {
            mostrarAlerta(mensaje: "Las contraseñas no coinciden.")
            return
        }
        guard opAceptarTeryCon.isOn else {
            mostrarAlerta(mensaje: "Debes aceptar los términos y condiciones.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else { return }

            let db = Firestore.firestore()
            db.collection("usuarios").document(uid).setData([
                "nombre": nombre,
                "fechaNacimiento": fecha,
                "email": email,
                "uid": uid
            ]) { error in
                if let error {
                    self.mostrarAlerta(mensaje: "Cuenta creada pero error al guardar datos: \(error.localizedDescription)")
                    return
                }
                self.mostrarAlerta(mensaje: "Cuenta creada correctamente.") {
                    self.irAPantallaLogin()
                }
            }
        }
    }

    @IBAction func volverIniciarSesion(_ sender: UIButton) {
        irAPantallaLogin()
    }

    func irAPantallaLogin() {
        dismiss(animated: true)
    }

    func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alerta, animated: true)
    }
}
