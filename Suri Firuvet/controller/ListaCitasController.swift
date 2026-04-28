import UIKit

class ListaCitasController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!

    var citas: [CitaDTO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupTapGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas()
    }

    func cargarCitas() {
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        CitaService.shared.listarCitas(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let citas):
                    self?.citas = citas
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.mostrarMensaje(titulo: "Error", mensaje: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitaCell", for: indexPath) as! CitaTableViewCell
        let cita = citas[indexPath.row]
        cell.lblMascota.text = cita.nombreMascota ?? "Mascota"
        cell.lblFechaHora.text = "Fecha: \(cita.fecha ?? "")"
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "irDetalleCita", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "irDetalleCita", let index = sender as? Int else { return }
        let destino = segue.destination as! DetallesCitaController
        destino.cita = citas[index]
    }

    // MARK: - Utilidades
    func mostrarMensaje(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
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
