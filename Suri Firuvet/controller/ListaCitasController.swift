import UIKit
import FirebaseAuth
import FirebaseFirestore

class ListaCitasController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!
    
    var citas: [[String: Any]] = []
    var citaIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupTapGestures()
        cargarCitas()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas()
    }

    func cargarCitas() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        CoreDataManager.shared.obtenerCitas(uid: uid) { [weak self] documentos in
            DispatchQueue.main.async {
                self?.citas = documentos.map { $0.data() }
                self?.citaIds = documentos.map { $0.documentID }
                self?.tableView.reloadData()
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
        cell.lblMascota.text = cita["mascota"] as? String ?? ""
        if let timestamp = cita["fechaHora"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            cell.lblFechaHora.text = "Fecha: \(formatter.string(from: timestamp.dateValue()))"
        }
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "irDetalleCita", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "irDetalleCita", let index = sender as? Int else { return }
        let destino = segue.destination as! DetallesCitaController
        destino.citaData = citas[index]
        destino.citaId = citaIds[index]
    }

    // MARK: - Gestos
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
