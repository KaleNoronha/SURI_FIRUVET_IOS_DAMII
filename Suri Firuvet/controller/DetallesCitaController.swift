import UIKit
import FirebaseFirestore

class DetallesCitaController: UIViewController {
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!

    @IBOutlet weak var lblMascota: UILabel!
    @IBOutlet weak var lblFechaHora: UILabel!
    @IBOutlet weak var lblLugar: UILabel!
    @IBOutlet weak var lblTipo: UILabel!
    @IBOutlet weak var lblComentario: UILabel!

    var citaData: [String: Any] = [:]
    var citaId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        cargarDatos()
    }

    private func cargarDatos() {
        lblMascota.text = citaData["mascota"] as? String ?? ""
        lblLugar.text = "Lugar: \(citaData["lugar"] as? String ?? "")"
        lblTipo.text = "Tipo: \(citaData["tipo"] as? String ?? "")"
        lblComentario.text = citaData["comentario"] as? String ?? ""
        if let timestamp = citaData["fechaHora"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            lblFechaHora.text = "Fecha: \(formatter.string(from: timestamp.dateValue()))"
        }
    }

    private func setupTapGestures() {
        let imagenes = [imgListaDeMascotas, imgPerfilPersonal, imgVolver]
        for imagen in imagenes {
            imagen?.isUserInteractionEnabled = true
            imagen?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagenTapped(_:))))
        }
    }

    @objc func imagenTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }
        switch viewTapped {
        case imgVolver:
            navigationController?.popViewController(animated: true) ?? { dismiss(animated: true) }()
        case imgListaDeMascotas:
            navegarA(identificador: "ListaMascotasController")
        case imgPerfilPersonal:
            navegarA(identificador: "PerfilPersonalController")
        default: break
        }
    }

    private func navegarA(identificador: String) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identificador) else { return }
        navigationController?.pushViewController(vc, animated: true) ?? { present(vc, animated: true) }()
    }
}
