import UIKit
import FirebaseAuth
import FirebaseFirestore

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

            // Guardar uid inmediatamente
            UserDefaults.standard.set(user.uid, forKey: "uid")

            // Obtener datos desde Firestore
            let db = Firestore.firestore()
            db.collection("usuarios").document(user.uid).getDocument { [weak self] snapshot, _ in
                guard let self else { return }

                let nombre = snapshot?.data()?["nombre"] as? String ?? ""
                let partes = nombre.components(separatedBy: " ")
                let nombCli = partes.first ?? ""
                let apeCli = partes.dropFirst().joined(separator: " ")
                let fecha = snapshot?.data()?["fechaNacimiento"] as? String

                // Buscar si existe en la API
                ClienteService.shared.buscarPorUid(user.uid) { result in
                    switch result {
                    case .success(let cliente):
                        if let cliente = cliente, let id = cliente.id {
                            // Ya existe, guardar id y navegar
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(id, forKey: "idCliente")
                                self.mostrarCarga(false)
                                self.irASiguientePantalla()
                            }
                        } else {
                            // No existe, crear cliente
                            let req = ClienteRequest(nombCli: nombCli, apeCli: apeCli, fecNac: fecha, uid: user.uid)
                            ClienteService.shared.crearCliente(req) { createResult in
                                DispatchQueue.main.async {
                                    self.mostrarCarga(false)
                                    if case .success(let nuevo) = createResult {
                                        UserDefaults.standard.set(nuevo.id ?? 0, forKey: "idCliente")
                                    }
                                    self.irASiguientePantalla()
                                }
                            }
                        }
                    case .failure:
                        DispatchQueue.main.async {
                            self.mostrarCarga(false)
                            self.irASiguientePantalla()
                        }
                    }
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
