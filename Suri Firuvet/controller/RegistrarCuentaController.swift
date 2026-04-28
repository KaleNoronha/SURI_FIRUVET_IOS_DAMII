import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrarCuentaController: UIViewController {

    @IBOutlet weak var txtNombreCompleto: UITextField!
    @IBOutlet weak var txtApellido: UITextField!
    @IBOutlet weak var dpFechaNacimiento: UIDatePicker!
    @IBOutlet weak var txtCorreoUsuario: UITextField!
    @IBOutlet weak var txtContrasenia: UITextField!
    @IBOutlet weak var txtRepetirContrasenia: UITextField!
    @IBOutlet weak var opAceptarTeryCon: UISwitch!
    @IBOutlet weak var btnCrearCuenta: UIButton!
    @IBOutlet weak var btnVolverIniciarSesion: UIButton!

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        txtContrasenia.isSecureTextEntry = true
        txtRepetirContrasenia.isSecureTextEntry = true
        configurarSpinner()
        dpFechaNacimiento.datePickerMode = .date
        dpFechaNacimiento.locale = Locale(identifier: "es_PE")
        dpFechaNacimiento.maximumDate = Date()
    }

private func configurarSpinner() {
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func mostrarCarga(_ mostrar: Bool) {
        DispatchQueue.main.async {
            if mostrar {
                self.spinner.startAnimating()
                self.btnCrearCuenta.isEnabled = false
                self.view.alpha = 0.8
            } else {
                self.spinner.stopAnimating()
                self.btnCrearCuenta.isEnabled = true
                self.view.alpha = 1.0
            }
        }
    }

    @IBAction func crearCuenta(_ sender: UIButton) {
        let nombre = txtNombreCompleto.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let apellido = txtApellido.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let fecha = formatter.string(from: dpFechaNacimiento.date)
        let email = txtCorreoUsuario.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pass = txtContrasenia.text ?? ""
        let repetirPass = txtRepetirContrasenia.text ?? ""

        guard !nombre.isEmpty, !apellido.isEmpty, !fecha.isEmpty, !email.isEmpty, !pass.isEmpty, !repetirPass.isEmpty else {
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

        mostrarCarga(true)

        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.mostrarCarga(false)
                self.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else {
                self.mostrarCarga(false)
                return
            }

            let db = Firestore.firestore()
            db.collection("usuarios").document(uid).setData([
                "nombre": nombre,
                "apellido": apellido,
                "fechaNacimiento": fecha,
                "email": email,
                "uid": uid
            ]) { error in
                if let error {
                    self.mostrarCarga(false)
                    self.mostrarAlerta(mensaje: "Cuenta creada pero error al guardar datos: \(error.localizedDescription)")
                    return
                }

                let req = ClienteRequest(nombCli: nombre, apeCli: apellido.isEmpty ? "-" : apellido, fecNac: fecha, uid: uid)

                ClienteService.shared.crearCliente(req) { _ in
                    DispatchQueue.main.async {
                        self.mostrarCarga(false)
                        self.mostrarAlerta(mensaje: "Cuenta creada correctamente.") {
                            self.irAPantallaLogin()
                        }
                    }
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
