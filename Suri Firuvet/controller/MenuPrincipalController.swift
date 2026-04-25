import UIKit

class MenuPrincipalController: UIViewController {
    @IBOutlet weak var imgCrearCita: UIImageView!
    @IBOutlet weak var imgIngresarMascota: UIImageView!
    @IBOutlet weak var imgListaDeCitas: UIImageView!
    
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    
    @IBOutlet weak var imgVolver: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
    }
    
    private func setupTapGestures() {
        let imagenes = [ imgCrearCita, imgIngresarMascota, imgListaDeCitas, imgListaDeMascotas, imgPerfilPersonal, imgVolver ]
        
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
            
        case imgCrearCita:
            navegarA(identificador: "CrearCitaController")
            
        case imgListaDeMascotas:
            navegarA(identificador: "ListaMascotasController")
            
        case imgIngresarMascota:
            navegarA(identificador: "IngresarMascotaController")
            
        case imgListaDeCitas:
            navegarA(identificador: "ListaCitasController")
            
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
