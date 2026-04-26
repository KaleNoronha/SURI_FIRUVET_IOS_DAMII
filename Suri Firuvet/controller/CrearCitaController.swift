import UIKit
import FirebaseAuth

class CrearCitaController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var pvMascota: UIPickerView?
    @IBOutlet weak var dpFechaHora: UIDatePicker?
    @IBOutlet weak var pvLugar: UIPickerView?
    @IBOutlet weak var pvTipo: UIPickerView?
    @IBOutlet weak var txtComentario: UITextField!
    @IBOutlet weak var imgListaDeMascotas: UIImageView?
    @IBOutlet weak var imgPerfilPersonal: UIImageView?
    @IBOutlet weak var imgVolver: UIImageView?
    
    //Listas de opciones
    let listaMascotas = ["Firulais", "Michi", "Rocky", "Luna"]
    let listaLugares = ["Clínica Central", "Sucursal Norte", "Sucursal Sur"]
    let listaTipos = ["Consulta General", "Vacunación", "Control", "Emergencia"]
    
    //Variables seleccionadas
    var mascotaSeleccionada: String = ""
    var lugarSeleccionado: String = ""
    var tipoSeleccionado: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGestures()
        //Configurar Pickers
        pvMascota?.delegate = self
        pvMascota?.dataSource = self
        mascotaSeleccionada = listaMascotas[0]
        
        pvLugar?.delegate = self
        pvLugar?.dataSource = self
        lugarSeleccionado = listaLugares[0]
        
        pvTipo?.delegate = self
        pvTipo?.dataSource = self
        tipoSeleccionado = listaTipos[0]
        
        dpFechaHora?.datePickerMode = .dateAndTime
        dpFechaHora?.locale = Locale(identifier: "es_PE")
        
        txtComentario?.text = ""
        txtComentario?.layer.borderColor = UIColor.lightGray.cgColor
        txtComentario?.layer.borderWidth = 1.0
        txtComentario?.layer.cornerRadius = 5.0
    }
    
    //PickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pvMascota { return listaMascotas.count }
        if pickerView == pvLugar { return listaLugares.count }
        if pickerView == pvTipo { return listaTipos.count }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pvMascota { return listaMascotas[row] }
        if pickerView == pvLugar { return listaLugares[row] }
        if pickerView == pvTipo { return listaTipos[row] }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pvMascota { mascotaSeleccionada = listaMascotas[row] }
        if pickerView == pvLugar { lugarSeleccionado = listaLugares[row] }
        if pickerView == pvTipo { tipoSeleccionado = listaTipos[row] }
    }
    
    // MARK: - Validación
    func validarCampos() -> String? {
        guard !mascotaSeleccionada.isEmpty else { return "Debe seleccionar una mascota" }
        guard !lugarSeleccionado.isEmpty else { return "Debe seleccionar un lugar" }
        guard !tipoSeleccionado.isEmpty else { return "Debe seleccionar un tipo de cita" }
        guard !(txtComentario?.text ?? "").isEmpty else { return "El comentario es obligatorio" }
        return nil
    }
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        if let error = validarCampos() {
                    mostrarMensaje(titulo: "Error", mensaje: error)
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    mostrarMensaje(titulo: "Error", mensaje: "No hay sesión activa.")
                    return
                }
                CoreDataManager.shared.insertarCita(
                    uid: uid,
                    mascota: mascotaSeleccionada,
                    fecha: dpFechaHora?.date ?? Date(),
                    lugar: lugarSeleccionado,
                    tipo: tipoSeleccionado,
                    comentario: txtComentario?.text ?? ""
                )
               
                mostrarMensaje(titulo: "Éxito", mensaje: "Cita registrada correctamente")
                limpiarCampos()
            }
            
            func limpiarCampos() {
                pvMascota?.selectRow(0, inComponent: 0, animated: true)
                mascotaSeleccionada = listaMascotas[0]
                pvLugar?.selectRow(0, inComponent: 0, animated: true)
                lugarSeleccionado = listaLugares[0]
                pvTipo?.selectRow(0, inComponent: 0, animated: true)
                tipoSeleccionado = listaTipos[0]
                dpFechaHora?.date = Date()
                txtComentario?.text = ""
            }
            
            func mostrarMensaje(titulo: String, mensaje: String) {
                let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
                alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
                present(alerta, animated: true)
            }

            private func setupTapGestures() {
                let imagenes = [imgListaDeMascotas, imgPerfilPersonal, imgVolver]
                for imagen in imagenes {
                    imagen?.isUserInteractionEnabled = true
                    imagen?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagenTapped(_:))))
                }
            }

            @objc func imagenTapped(_ sender: UITapGestureRecognizer) {
                guard let view = sender.view else { return }
                switch view {
                case imgVolver:
                    if let nav = navigationController { nav.popViewController(animated: true) }
                    else { dismiss(animated: true) }
                case imgListaDeMascotas:
                    navegarA(identificador: "ListaMascotasController")
                case imgPerfilPersonal:
                    navegarA(identificador: "PerfilPersonalController")
                default: break
                }
            }

            private func navegarA(identificador: String) {
                guard let vc = storyboard?.instantiateViewController(withIdentifier: identificador) else { return }
                if let nav = navigationController { nav.pushViewController(vc, animated: true) }
                else { present(vc, animated: true) }
            }
        }
