# Módulo de Citas — Suri Firuvet 🐾

Documentación técnica de las pantallas **Crear Cita** y **Lista de Citas**.

---

## CrearCitaController

### Descripción
Pantalla que permite registrar una nueva cita veterinaria seleccionando mascota, lugar, tipo, fecha/hora y un comentario.

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/CrearCitaController.swift` | Lógica de la pantalla |
| `CoreData/CoreDataManager.swift` | Persistencia local |
| `Base.lproj/Main.storyboard` | Interfaz visual |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `pvMascota` | `UIPickerView?` | Selector de mascota |
| `pvLugar` | `UIPickerView?` | Selector de lugar/clínica |
| `pvTipo` | `UIPickerView?` | Selector de tipo de cita |
| `dpFechaHora` | `UIDatePicker?` | Selector de fecha y hora |
| `txtComentario` | `UITextField!` | Campo de comentario |
| `imgVolver` | `UIImageView?` | Botón volver |
| `imgListaDeMascotas` | `UIImageView?` | Navega a lista de mascotas |
| `imgPerfilPersonal` | `UIImageView?` | Navega a perfil personal |

### Listas de opciones
```swift
let listaMascotas = ["Firulais", "Michi", "Rocky", "Luna"]
let listaLugares  = ["Clínica Central", "Sucursal Norte", "Sucursal Sur"]
let listaTipos    = ["Consulta General", "Vacunación", "Control", "Emergencia"]
```
> Estas listas pueden reemplazarse por datos dinámicos desde una API en el futuro.

### Flujo de registro
```
Usuario llena formulario
        ↓
btnRegistrar() → validarCampos()
        ↓ error                  ↓ válido
mostrarMensaje("Error")    CoreDataManager.insertarCita(...)
                                 ↓
                           mostrarMensaje("Éxito")
                                 ↓
                           limpiarCampos()
```

### Validaciones
| Campo | Regla |
|---|---|
| Mascota | No puede estar vacío |
| Lugar | No puede estar vacío |
| Tipo | No puede estar vacío |
| Comentario | No puede estar vacío |

### Guardado en Core Data
```swift
CoreDataManager.shared.insertarCita(
    mascota:    mascotaSeleccionada,
    fecha:      dpFechaHora?.date ?? Date(),
    lugar:      lugarSeleccionado,
    tipo:       tipoSeleccionado,
    comentario: txtComentario?.text ?? ""
)
```

---

## ListaCitasController

### Descripción
Pantalla que muestra todas las citas en una `UITableView`. Consume primero una API REST y usa Core Data como fallback si la API no responde.

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/ListaCitasController.swift` | Lógica de la pantalla |
| `servicios/CitaService.swift` | Consumo de API REST |
| `modelo/CitaDTO.swift` | Modelo de datos de la API |
| `CoreData/CoreDataManager.swift` | Fallback local |
| `Cells/CitaTableViewCell.swift` | Celda personalizada |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `tableView` | `UITableView!` | Lista de citas |
| `imgVolver` | `UIImageView!` | Botón volver |
| `imgListaDeMascotas` | `UIImageView!` | Navega a lista de mascotas |
| `imgPerfilPersonal` | `UIImageView!` | Navega a perfil personal |

### Fuentes de datos
```swift
var citasDTO: [CitaDTO]    // Datos desde la API REST (prioridad)
var citas:    [CitaEntity] // Fallback desde Core Data
```

### Flujo de carga
```
viewDidLoad / viewWillAppear
        ↓
cargarCitasDesdeAPI()
        ↓ éxito                  ↓ fallo
citasDTO = data            cargarCitasCoreData()
tableView.reloadData()     citas = CoreDataManager.obtenerCitas()
                           tableView.reloadData()
```

### Configuración de la API
```swift
// servicios/CitaService.swift
private let baseURL = "https://tu-api.com/api/citas"  // ← reemplazar con URL real

// Si requiere autenticación:
request.setValue("Bearer <token>", forHTTPHeaderField: "Authorization")
```

### Mapeo JSON — CitaDTO
```swift
struct CitaDTO: Codable {
    let id:         Int?
    let mascota:    String?
    let fechaHora:  String?  // JSON key: "fecha_hora"
    let lugar:      String?
    let tipo:       String?
    let comentario: String?
}
```
> El campo `fecha_hora` del JSON se mapea a `fechaHora` en Swift mediante `CodingKeys`.

### Celda — CitaTableViewCell
| Outlet | Muestra |
|---|---|
| `lblMascota` | Nombre de la mascota |
| `lblFechaHora` | Fecha y hora formateada |

### Navegación al detalle
Al tocar una celda se ejecuta el segue `irDetalleCita`:
```swift
// Datos desde API
performSegue(withIdentifier: "irDetalleCita", sender: citasDTO[indexPath.row])

// Datos desde Core Data
performSegue(withIdentifier: "irDetalleCita", sender: citas[indexPath.row])
```
`DetallesCitaController` acepta tanto `CitaDTO` como `CitaEntity`.

---

## Relación entre pantallas

```
MenuPrincipalController
        ↓
CrearCitaController ──────────────→ CoreData (guarda)

ListaCitasController → CitaService (API)
        │                    ↓ fallo
        │              CoreDataManager (local)
        ↓
DetallesCitaController
```
