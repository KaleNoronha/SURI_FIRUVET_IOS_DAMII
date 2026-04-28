import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var txtCorreoUsuario: UITextField!
    @IBOutlet weak var txtContrasenia: UITextField!
    @IBOutlet weak var btnIngresarSistema: UIButton!
    @IBOutlet weak var btnRegistrarNuevaCuenta: UIButton!

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        txtContrasenia.isSecureTextEntry = true
        configurarSpinner()
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
                self.btnIngresarSistema.isEnabled = false
                self.view.alpha = 0.8
            } else {
                self.spinner.stopAnimating()
                self.btnIngresarSistema.isEnabled = true
                self.view.alpha = 1.0
            }
        }
    }

    @IBAction func ingresarSistema(_ sender: UIButton) {
        let email = txtCorreoUsuario.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pass = txtContrasenia.text ?? ""

        guard !email.isEmpty, !pass.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, ingresa usuario y contraseña.")
            return
        }

        mostrarCarga(true)

        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.mostrarCarga(false)
                self.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user else {
                self.mostrarCarga(false)
                return
            }

            let nombre = user.displayName ?? email.components(separatedBy: "@").first ?? "Usuario"

            ClienteService.shared.sincronizarCliente(uid: user.uid, nombre: nombre, apellido: "") { syncResult in
                DispatchQueue.main.async {
                    self.mostrarCarga(false)
                    UserDefaults.standard.set(user.uid, forKey: "uid")
                    switch syncResult {
                    case .success(let idCliente):
                        UserDefaults.standard.set(idCliente, forKey: "idCliente")
                    case .failure:
                        break
                    }
                    self.irASiguientePantalla()
                }
            }
        }
    }

    @IBAction func registrarNuevaCuenta(_ sender: UIButton) {
        performSegue(withIdentifier: "irRegistrarCuenta", sender: nil)
    }

    func irASiguientePantalla() {
        performSegue(withIdentifier: "irMenuPrincipal", sender: nil)
    }

    func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alerta, animated: true)
    }
}
