import UIKit

class PerfilMascotaController: UIViewController {

    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtEspecie: UITextField!   // solo lectura (Especie)
    @IBOutlet weak var txtApodos: UITextField!
    @IBOutlet weak var txtAlergias: UITextField!

    var mascota: MascotaEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        cargarDatos()
    }

    private func cargarDatos() {
        guard let m = mascota else { return }
        txtNombre.text   = m.nombre
        txtEspecie.text  = m.tipo ?? "-"
        txtApodos.text   = m.apodos
        txtAlergias.text = m.alergias
    }

    // MARK: - Guardar cambios (Core Data local)
    @IBAction func btnGuardar(_ sender: UIButton) {
        guard let m = mascota else { return }
        CoreDataManager.shared.actualizarMascotaLocal(
            idRemoto: m.idRemoto,
            nombre:   txtNombre.text,
            apodos:   txtApodos.text,
            alergias: txtAlergias.text
        )
        mostrarAlerta(mensaje: "Cambios guardados localmente.")
    }

    // MARK: - Eliminar mascota
    @IBAction func btnEliminar(_ sender: UIButton) {
        guard let m = mascota else { return }
        let alerta = UIAlertController(title: "Confirmar", message: "\u00bfEliminar esta mascota?", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            CoreDataManager.shared.eliminarMascotaLocal(idRemoto: m.idRemoto)
            self?.navigationController?.popViewController(animated: true)
        })
        present(alerta, animated: true)
    }

    private func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    // MARK: - Navegación
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
