import UIKit

class IngresarMascotaController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var imgListaDeMascotas: UIImageView!
    @IBOutlet weak var imgPerfilPersonal: UIImageView!
    @IBOutlet weak var imgVolver: UIImageView!
    @IBOutlet weak var txtNombreMascota: UITextField!
    @IBOutlet weak var txtEspecie: UITextField!
    @IBOutlet weak var txtAlergias: UITextField!
    @IBOutlet weak var txtApodosMascota: UITextField!
    @IBOutlet weak var btnRegistrarMascota: UIButton!
    

    private let spinner = UIActivityIndicatorView(style: .large)
    private let pickerEspecie = UIPickerView()
    private var tiposMascota: [TipoMascotaDTO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        configurarSpinner()
        configurarPickerEspecie()
        cargarTiposMascota()
    }

    // MARK: - Spinner
    private func configurarSpinner() {
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func mostrarCarga(_ mostrar: Bool) {
        DispatchQueue.main.async {
            if mostrar {
                self.spinner.startAnimating()
                self.btnRegistrarMascota.isEnabled = false
                self.view.alpha = 0.8
            } else {
                self.spinner.stopAnimating()
                self.btnRegistrarMascota.isEnabled = true
                self.view.alpha = 1.0
            }
        }
    }

    // MARK: - Picker Especie
    private func configurarPickerEspecie() {
        pickerEspecie.delegate = self
        pickerEspecie.dataSource = self
        txtEspecie.inputView = pickerEspecie
        txtEspecie.tintColor = .clear

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let btnDone: UIBarButtonItem
        if #available(iOS 26.0, *) {
            btnDone = UIBarButtonItem(title: "Listo", style: .prominent, target: self, action: #selector(cerrarPicker))
        } else {
            btnDone = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(cerrarPicker))
        }
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), btnDone], animated: false)
        txtEspecie.inputAccessoryView = toolbar
    }

    @objc private func cerrarPicker() {
        txtEspecie.resignFirstResponder()
    }

    private func cargarTiposMascota() {
        TipoMascotaService.shared.listarTipos { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let tipos) = result {
                    self?.tiposMascota = tipos
                    self?.pickerEspecie.reloadAllComponents()
                    if let primero = tipos.first {
                        self?.txtEspecie.text = primero.nombre
                    }
                }
            }
        }
    }

    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        tiposMascota.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        tiposMascota[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtEspecie.text = tiposMascota[row].nombre
    }

    // MARK: - Registrar Mascota
    @IBAction func registrarMascota(_ sender: UIButton) {
        let nombre = txtNombreMascota.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !nombre.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, ingresa el nombre de la mascota.")
            return
        }
        guard !tiposMascota.isEmpty else {
            mostrarAlerta(mensaje: "No se pudieron cargar los tipos de mascota.")
            return
        }

        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        guard !uid.isEmpty else {
            mostrarAlerta(mensaje: "Sesión no válida. Por favor inicia sesión nuevamente.")
            return
        }

        let tipoIndex = pickerEspecie.selectedRow(inComponent: 0)
        let idTipo = tiposMascota[tipoIndex].id

        mostrarCarga(true)

        let apodos = txtApodosMascota.text?.trimmingCharacters(in: .whitespaces)
        let alergias = txtAlergias.text?.trimmingCharacters(in: .whitespaces)

        MascotaService.shared.crearMascota(MascotaRequest(
            uid: uid,
            nombMas: nombre,
            idTipoMascota: idTipo,
            apodos: apodos?.isEmpty == true ? nil : apodos,
            alergias: alergias?.isEmpty == true ? nil : alergias
        )) { [weak self] result in
            DispatchQueue.main.async {
                self?.mostrarCarga(false)
                switch result {
                case .success(let nueva):
                    CoreDataManager.shared.agregarMascotaLocal(nueva, uid: uid)
                    self?.mostrarAlerta(mensaje: "Mascota registrada correctamente.") {
                        self?.limpiarCampos()
                    }
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Limpiar campos
    func limpiarCampos() {
        txtNombreMascota.text = ""
        txtEspecie.text = tiposMascota.first?.nombre ?? ""
        txtAlergias.text = ""
        txtApodosMascota.text = ""
        pickerEspecie.selectRow(0, inComponent: 0, animated: false)
    }

    func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
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
