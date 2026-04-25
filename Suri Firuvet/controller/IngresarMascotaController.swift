import UIKit

class IngresarMascotaController: UIViewController {
    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    
    @IBOutlet weak var imgVolver: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
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
    
    
    
    
    @IBOutlet weak var txtNombreMascota: UITextField!
    
    @IBOutlet weak var txtEspecie: UITextField!
    
    @IBOutlet weak var txtAlergias: UITextField!
    
    @IBOutlet weak var txtApodosMascota: UITextField!
    
    
    
    @IBOutlet weak var btnRegistrarMascota: UIButton!
    

    
    
    // MARK: - Acción Registrar Mascota
        @IBAction func registrarMascota(_ sender: UIButton) {
            
            let nombre = txtNombreMascota.text ?? ""
            let especie = txtEspecie.text ?? ""
            let alergias = txtAlergias.text ?? ""
            let apodos = txtApodosMascota.text ?? ""
            
            // 1. Validar solo campos obligatorios
            if nombre.isEmpty || especie.isEmpty {
                mostrarAlerta(mensaje: "Por favor, completa los campos obligatorios (Nombre y Especie).")
                return
            }
            
            // 2. Registro simulado (por ahora)
            print("Mascota registrada:")
            print("Nombre: \(nombre)")
            print("Especie: \(especie)")
            print("Alergias: \(alergias)")
            print("Apodos: \(apodos)")
            
            // 3. Confirmación al usuario
            mostrarAlerta(mensaje: "Mascota registrada correctamente.") {
                self.limpiarCampos()
            }
        }
        
        // MARK: - Limpiar campos
        func limpiarCampos() {
            txtNombreMascota.text = ""
            txtEspecie.text = ""
            txtAlergias.text = ""
            txtApodosMascota.text = ""
        }
        
        // MARK: - Alertas reutilizables
        func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
            let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
            
            let accion = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            
            alerta.addAction(accion)
            present(alerta, animated: true)
        }
    

    
}
