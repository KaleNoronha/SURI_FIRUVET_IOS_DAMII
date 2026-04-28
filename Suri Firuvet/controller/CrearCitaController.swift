import UIKit

class CrearCitaController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pvMascota: UIPickerView?
    @IBOutlet weak var dpFechaHora: UIDatePicker?
    @IBOutlet weak var pvLugar: UIPickerView?
    @IBOutlet weak var pvTipo: UIPickerView?
    @IBOutlet weak var txtComentario: UITextField!
    @IBOutlet weak var imgListaDeMascotas: UIImageView?
    @IBOutlet weak var imgPerfilPersonal: UIImageView?
    @IBOutlet weak var imgVolver: UIImageView?

    var mascotas: [MascotaDTO] = []
    var clinicas: [ClinicaDTO] = []
    var tiposCita: [TipoCitaDTO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        configurarPickers()
        configurarUI()
        cargarDatos()
    }

    private func configurarPickers() {
        pvMascota?.delegate = self
        pvMascota?.dataSource = self
        pvLugar?.delegate = self
        pvLugar?.dataSource = self
        pvTipo?.delegate = self
        pvTipo?.dataSource = self
    }

    private func configurarUI() {
        dpFechaHora?.datePickerMode = .dateAndTime
        dpFechaHora?.locale = Locale(identifier: "es_PE")
        txtComentario?.text = ""
        txtComentario?.layer.borderColor = UIColor.lightGray.cgColor
        txtComentario?.layer.borderWidth = 1.0
        txtComentario?.layer.cornerRadius = 5.0
    }

    private func cargarDatos() {
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        MascotaService.shared.listarMascotas(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let lista) = result {
                    self?.mascotas = lista
                    self?.pvMascota?.reloadAllComponents()
                }
            }
        }
        ClinicaService.shared.listarClinicas { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let lista) = result {
                    self?.clinicas = lista
                    self?.pvLugar?.reloadAllComponents()
                }
            }
        }
        TipoCitaService.shared.listarTipos { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let lista) = result {
                    self?.tiposCita = lista
                    self?.pvTipo?.reloadAllComponents()
                }
            }
        }
    }

    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pvMascota { return mascotas.count }
        if pickerView == pvLugar { return clinicas.count }
        if pickerView == pvTipo { return tiposCita.count }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pvMascota { return mascotas[row].nombMas }
        if pickerView == pvLugar { return clinicas[row].nombre }
        if pickerView == pvTipo { return tiposCita[row].nombre }
        return nil
    }

    // MARK: - Registrar cita
    @IBAction func btnRegistrar(_ sender: UIButton) {
        guard !mascotas.isEmpty, !clinicas.isEmpty, !tiposCita.isEmpty else {
            mostrarMensaje(titulo: "Error", mensaje: "Faltan datos para crear la cita.")
            return
        }

        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let mascotaIndex = pvMascota?.selectedRow(inComponent: 0) ?? 0
        let clinicaIndex = pvLugar?.selectedRow(inComponent: 0) ?? 0
        let tipoIndex = pvTipo?.selectedRow(inComponent: 0) ?? 0

        let request = CrearCitaRequest(
            uid: uid,
            idTipoCita: tiposCita[tipoIndex].id,
            fecha: formatter.string(from: dpFechaHora?.date ?? Date()),
            comentario: txtComentario?.text,
            idMascota: mascotas[mascotaIndex].id,
            idClinica: clinicas[clinicaIndex].id
        )

        CitaService.shared.crearCita(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.mostrarMensaje(titulo: "Éxito", mensaje: "Cita registrada correctamente")
                    self?.limpiarCampos()
                case .failure(let error):
                    self?.mostrarMensaje(titulo: "Error", mensaje: error.localizedDescription)
                }
            }
        }
    }

    func limpiarCampos() {
        pvMascota?.selectRow(0, inComponent: 0, animated: true)
        pvLugar?.selectRow(0, inComponent: 0, animated: true)
        pvTipo?.selectRow(0, inComponent: 0, animated: true)
        dpFechaHora?.date = Date()
        txtComentario?.text = ""
    }

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
        guard let view = sender.view else { return }
        switch view {
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
