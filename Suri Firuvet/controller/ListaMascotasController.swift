import UIKit

class ListaMascotasController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!

    private var mascotas: [MascotaEntity] = []
    private let uid = UserDefaults.standard.string(forKey: "uid") ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.rowHeight = 154
        tableView.estimatedRowHeight = 154
        setupTapGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
    }

    // MARK: - Carga desde API + Core Data
    private func cargarMascotas() {
        let uid = self.uid
        MascotaService.shared.listarMascotas(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let remotas) = result, !remotas.isEmpty {
                    CoreDataManager.shared.guardarMascotas(remotas, uid: uid)
                }
                self?.mascotas = CoreDataManager.shared.obtenerMascotasLocales(uid: uid)
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mascotas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MascotaCell", for: indexPath)
        let m = mascotas[indexPath.row]
        (cell.viewWithTag(1) as? UILabel)?.text = m.nombre ?? "Sin nombre"
        (cell.viewWithTag(2) as? UILabel)?.text = "Especie: \(m.tipo ?? "-")"
        (cell.viewWithTag(3) as? UILabel)?.text = "Apodos: \(m.apodos ?? "-")"
        (cell.viewWithTag(4) as? UILabel)?.text = "Alergias: \(m.alergias ?? "-")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "PerfilMascotaController") as? PerfilMascotaController else { return }
        vc.mascota = mascotas[indexPath.row]
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Eliminar con swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let mascota = mascotas[indexPath.row]
        CoreDataManager.shared.eliminarMascotaLocal(idRemoto: mascota.idRemoto)
        mascotas.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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
