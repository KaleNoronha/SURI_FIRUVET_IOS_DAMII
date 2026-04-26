import UIKit

class ListaCitasController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    
    @IBOutlet weak var imgVolver: UIImageView!
    
    // Fuente de datos unificada desde API
    var citasDTO: [CitaDTO] = []
    // Fallback Core Data
    var citas: [CitaEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupTapGestures()
        cargarCitasDesdeAPI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitasDesdeAPI()
    }

    // MARK: - API
    func cargarCitasDesdeAPI() {
        CitaService.shared.obtenerCitas { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.citasDTO = data
                    self?.tableView.reloadData()
                case .failure:
                    // Fallback a Core Data si la API falla
                    self?.cargarCitasCoreData()
                }
            }
        }
    }

    func cargarCitasCoreData() {
        citas = CoreDataManager.shared.obtenerCitas()
        tableView.reloadData()
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citasDTO.isEmpty ? citas.count : citasDTO.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitaCell", for: indexPath) as! CitaTableViewCell

        if !citasDTO.isEmpty {
            let cita = citasDTO[indexPath.row]
            cell.lblMascota.text = cita.mascota ?? ""
            cell.lblFechaHora.text = "Fecha: \(cita.fechaHora ?? "")"
        } else {
            let cita = citas[indexPath.row]
            cell.lblMascota.text = cita.mascota ?? ""
            if let fecha = cita.fechaHora {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                cell.lblFechaHora.text = "Fecha: \(formatter.string(from: fecha))"
            }
        }
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !citasDTO.isEmpty {
            performSegue(withIdentifier: "irDetalleCita", sender: citasDTO[indexPath.row])
        } else {
            performSegue(withIdentifier: "irDetalleCita", sender: citas[indexPath.row])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "irDetalleCita" else { return }
        let destino = segue.destination as! DetallesCitaController
        if let dto = sender as? CitaDTO {
            destino.citaDTO = dto
        } else if let entity = sender as? CitaEntity {
            destino.cita = entity
        }
    }
        
        //Gestos en imágenes
        private func setupTapGestures() {
            let imagenes = [ imgListaDeMascotas, imgPerfilPersonal, imgVolver ]
            
            for imagen in imagenes {
                imagen?.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagenTapped(_:)))
                imagen?.addGestureRecognizer(tapGesture)
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
            
        default:
            break
        }
    }
    
    private func navegarA(identificador: String) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identificador) else {
            print("Error: No se encontro el ID \(identificador)")
            return
        }
        
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
}
