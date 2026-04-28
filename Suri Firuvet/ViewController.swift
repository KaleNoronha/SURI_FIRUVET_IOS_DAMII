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
            print("[LOGIN] UID obtenido: \(user.uid)")

            // Obtener datos desde Firestore
            let db = Firestore.firestore()
            db.collection("usuarios").document(user.uid).getDocument { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    print("[LOGIN] Error al obtener Firestore: \(error.localizedDescription)")
                }

                let nombre = snapshot?.data()?["nombre"] as? String ?? ""
                let fecha = snapshot?.data()?["fechaNacimiento"] as? String
                print("[LOGIN] Datos Firestore - nombre: \(nombre), fecha: \(String(describing: fecha))")

                let partes = nombre.components(separatedBy: " ")
                let nombCli = partes.first ?? ""
                let apeCli = partes.dropFirst().joined(separator: " ")

                // Buscar si existe en la API
                print("[LOGIN] Buscando cliente por uid en API...")
                ClienteService.shared.buscarPorUid(user.uid) { result in
                    switch result {
                    case .success(let cliente):
                        if let cliente = cliente, let id = cliente.id {
                            print("[LOGIN] Cliente encontrado en API - idCliente: \(id)")
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(id, forKey: "idCliente")
                                self.mostrarCarga(false)
                                self.irASiguientePantalla()
                            }
                        } else {
                            print("[LOGIN] Cliente NO existe en API, creando...")
                            let req = ClienteRequest(nombCli: nombCli, apeCli: apeCli, fecNac: fecha, uid: user.uid)
                            ClienteService.shared.crearCliente(req) { createResult in
                                switch createResult {
                                case .success(let nuevo):
                                    print("[LOGIN] Cliente creado en API - idCliente: \(String(describing: nuevo.id))")
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.set(nuevo.id ?? 0, forKey: "idCliente")
                                        self.mostrarCarga(false)
                                        self.irASiguientePantalla()
                                    }
                                case .failure(let error):
                                    print("[LOGIN] Error al crear cliente: \(error.localizedDescription)")
                                    DispatchQueue.main.async {
                                        self.mostrarCarga(false)
                                        self.irASiguientePantalla()
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                        print("[LOGIN] Error al buscar cliente: \(error.localizedDescription)")
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
