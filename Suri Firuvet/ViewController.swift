import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var txtCorreoUsuario: UITextField!
    @IBOutlet weak var txtContrasenia: UITextField!
    @IBOutlet weak var btnIngresarSistema: UIButton!
    @IBOutlet weak var btnRegistrarNuevaCuenta: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtContrasenia.isSecureTextEntry = true
    }
    
    @IBAction func ingresarSistema(_ sender: UIButton) {
        let email = txtCorreoUsuario.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pass = txtContrasenia.text ?? ""
        
        guard !email.isEmpty, !pass.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, ingresa usuario y contraseña.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                return
            }
            self.irASiguientePantalla()
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
