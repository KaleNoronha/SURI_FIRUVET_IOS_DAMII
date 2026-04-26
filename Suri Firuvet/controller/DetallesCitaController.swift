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
    
    var cita: CitaEntity?
    var citaDTO: CitaDTO?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        cargarDatos()
    }

    private func cargarDatos() {
        if let dto = citaDTO {
            lblMascota.text = dto.mascota ?? ""
            lblLugar.text = "Lugar: \(dto.lugar ?? "")"
            lblTipo.text = "Tipo: \(dto.tipo ?? "")"
            lblFechaHora.text = "Fecha: \(dto.fechaHora ?? "")"
            lblComentario.text = dto.comentario ?? ""
        } else if let cita = cita {
            lblMascota.text = cita.mascota ?? ""
            lblLugar.text = "Lugar: \(cita.lugar ?? "")"
            lblTipo.text = "Tipo: \(cita.tipo ?? "")"
            lblComentario.text = cita.comentario ?? ""
            if let fecha = cita.fechaHora {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                lblFechaHora.text = "Fecha: \(formatter.string(from: fecha))"
            }
        }
    }
    
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
