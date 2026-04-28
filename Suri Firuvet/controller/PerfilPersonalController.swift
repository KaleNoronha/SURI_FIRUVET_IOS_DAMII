import UIKit
import FirebaseAuth
import FirebaseFirestore

class PerfilPersonalController: UIViewController {

    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!
    
    @IBOutlet weak var txtApellido: UITextField!
    @IBOutlet weak var txtNombreCompleto: UITextField!
    @IBOutlet weak var txtFechaNacimiento: UITextField!
    @IBOutlet weak var txtCorreoElectronico: UITextField!
    @IBOutlet weak var txtTelefono: UITextField!


    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        cargarDatosUsuario()
    }

    private func cargarDatosUsuario() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("usuarios").document(uid).getDocument { [weak self] snapshot, error in
            guard let self, let data = snapshot?.data(), error == nil else { return }
            DispatchQueue.main.async {
                self.txtNombreCompleto.text  = data["nombre"] as? String ?? ""
                self.txtFechaNacimiento.text = data["fechaNacimiento"] as? String ?? ""
                self.txtCorreoElectronico.text = data["email"] as? String ?? ""
                self.txtTelefono.text = data["telefono"] as? String ?? ""
                self.txtApellido.text = data["apellido"] as? String ?? ""
            }
        }
    }

    @IBAction func guardarCambios(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let nombre = txtNombreCompleto.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let fecha = txtFechaNacimiento.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let telefono = txtTelefono.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let apellido = txtApellido.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !nombre.isEmpty else {
            mostrarAlerta(mensaje: "El nombre no puede estar vacío.")
            return
        }

        db.collection("usuarios").document(uid).updateData([
            "nombre": nombre,
            "fechaNacimiento": fecha,
            "telefono": telefono,
            "apellido": apellido
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.mostrarAlerta(mensaje: "Error al guardar: \(error.localizedDescription)")
                } else {
                    self?.mostrarAlerta(mensaje: "Perfil actualizado correctamente.")
                }
            }
        }
    }

    private func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    private func setupTapGestures() {
        let imagenes = [imgListaDeMascotas, imgPerfilPersonal, imgVolver]
        for imagen in imagenes {
            imagen?.isUserInteractionEnabled = true
            imagen?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagenTapped(_:))))
        }
    }

    @objc private func imagenTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }
        switch viewTapped {
        case imgVolver:
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        case imgListaDeMascotas:
            navegarA(identificador: "ListaMascotasController")
        case imgPerfilPersonal:
            break
        default:
            break
        }
    }

    private func navegarA(identificador: String) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identificador) else { return }
        navigationController?.pushViewController(vc, animated: true) ?? { present(vc, animated: true) }()
    }
}
