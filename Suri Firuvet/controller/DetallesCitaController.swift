import UIKit

class DetallesCitaController: UIViewController {

    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!

    @IBOutlet weak var lblMascota: UILabel!
    @IBOutlet weak var lblFechaHora: UILabel!
    @IBOutlet weak var lblLugar: UILabel!
    @IBOutlet weak var lblTipo: UILabel!
    @IBOutlet weak var lblComentario: UILabel!

    var cita: CitaDTO?

    @IBOutlet weak var btnEliminar: UIButton!
    @IBOutlet weak var btnModificar: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        cargarDatos()
    }

    private func cargarDatos() {
        guard let cita = cita else { return }
        lblMascota.text = cita.nombreMascota ?? "Mascota"
        lblFechaHora.text = cita.fecha ?? "-"
        lblLugar.text = cita.nombreClinica ?? "-"
        lblTipo.text = cita.nombreTipoCita ?? "-"
        lblComentario.text = cita.comentario ?? "Sin comentario"
    }

    // MARK: - Eliminar Cita
    @IBAction func btnEliminarCita(_ sender: UIButton) {
        guard let id = cita?.idCita else { return }
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""

        let alerta = UIAlertController(title: "Confirmar", message: "¿Deseas eliminar esta cita?", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
            CitaService.shared.eliminarCita(id: id, uid: uid) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.mostrarMensaje(titulo: "Éxito", mensaje: "Cita eliminada correctamente") {
                            guard let self = self else { return }
                            if let nav = self.navigationController {
                                let vcs = nav.viewControllers
                                if let lista = vcs.first(where: { $0 is ListaCitasController }) {
                                    nav.popToViewController(lista, animated: true)
                                } else {
                                    nav.popViewController(animated: true)
                                }
                            } else {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListaCitasController")
                                vc.map { $0.modalPresentationStyle = .fullScreen; self.present($0, animated: true) }
                            }
                        }
                    case .failure(let error):
                        self?.mostrarMensaje(titulo: "Error", mensaje: error.localizedDescription)
                    }
                }
            }
        })
        present(alerta, animated: true)
    }

    // MARK: - Modificar Cita
    @IBAction func btnModificarCita(_ sender: UIButton) {
        guard let cita = cita, let id = cita.idCita else { return }
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""

        let ac = UIAlertController(title: "Modificar Cita", message: "Edita el comentario", preferredStyle: .alert)
        ac.addTextField { tf in tf.text = cita.comentario }

        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        ac.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            let nuevoComentario = ac.textFields?.first?.text ?? ""

            let request = CrearCitaRequest(
                uid: uid,
                idTipoCita: cita.idCita ?? 1,
                fecha: cita.fecha ?? "",
                comentario: nuevoComentario,
                idMascota: cita.idMascota ?? 1,
                idClinica: cita.idClinica ?? 1
            )

            CitaService.shared.modificarCita(id: id, request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let citaActualizada):
                        self?.cita = citaActualizada
                        self?.cargarDatos()
                        self?.mostrarMensaje(titulo: "Éxito", mensaje: "Cita modificada correctamente")
                    case .failure(let error):
                        self?.mostrarMensaje(titulo: "Error", mensaje: error.localizedDescription)
                    }
                }
            }
        })
        present(ac, animated: true)
    }

    // MARK: - Utilidades
    func mostrarMensaje(titulo: String, mensaje: String, completion: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in completion?() })
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
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
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
