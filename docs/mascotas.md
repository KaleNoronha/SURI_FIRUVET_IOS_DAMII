# Módulo de Mascotas — Suri Firuvet 🐾

Documentación técnica de las pantallas **Ingresar Mascota**, **Lista de Mascotas** y **Perfil de Mascota**.

---

## IngresarMascotaController

### Descripción
Formulario para registrar una nueva mascota. Carga los tipos de mascota desde la API y envía el registro al backend.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `API REST` | GET tipos de mascota / POST nueva mascota |
| `UserDefaults` | Lee el `uid` del usuario activo |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/IngresarMascotaController.swift` | Lógica de la pantalla |
| `servicios/MascotaService.swift` | POST `/api/mascotas` |
| `servicios/TipoMascotaService.swift` | GET `/api/tipos-mascota` |
| `modelo/MascotaDTO.swift` | `MascotaRequest` |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `txtNombreMascota` | `UITextField` | Nombre de la mascota |
| `txtEspecie` | `UITextField` | Especie (controlado por picker) |
| `txtAlergias` | `UITextField` | Alergias (opcional) |
| `txtApodosMascota` | `UITextField` | Apodos (opcional) |

### Flujo de carga de tipos
```
viewDidLoad()
        ↓
TipoMascotaService.listarTipos()   [GET /api/tipos-mascota]
        ↓ éxito
tiposMascota = [TipoMascotaDTO]
pickerEspecie.reloadAllComponents()
txtEspecie.text = tiposMascota.first?.nombre
```

### Flujo de registro
```
btnRegistrarMascota()
        ↓
Validaciones:
  - nombre vacío → mostrarAlerta()
  - tiposMascota vacío → mostrarAlerta()
  - uid vacío → mostrarAlerta()
        ↓ válido
uid = UserDefaults.standard.string(forKey: "uid")
idTipo = tiposMascota[pickerEspecie.selectedRow].id

MascotaService.crearMascota(MascotaRequest(
    uid, nombMas, idTipoMascota, apodos?, alergias?
))   [POST /api/mascotas]
        ↓ error              ↓ éxito
mostrarAlerta(error)   mostrarAlerta("Mascota registrada")
                             ↓
                       limpiarCampos()
```

### API — Endpoints usados
```
GET  /api/tipos-mascota          → [TipoMascotaDTO]
POST /api/mascotas               → MascotaDTO
     Body: { uid, nombMas, idTipoMascota, apodos?, alergias? }
```

---

## ListaMascotasController

### Descripción
Lista todas las mascotas del usuario leyendo exclusivamente desde Core Data local. Las mascotas llegan a Core Data cuando se registran desde `IngresarMascotaController`.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `Core Data` | Fuente única de datos |
| `UserDefaults` | Lee el `uid` para filtrar mascotas del usuario |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/ListaMascotasController.swift` | Lógica de la pantalla |
| `CoreData/CoreDataManager.swift` | `obtenerMascotasLocales()` / `eliminarMascotaLocal()` |
| `CoreData/SuriFiruvet.xcdatamodeld` | Entidad `MascotaEntity` |

### Entidad Core Data — MascotaEntity
| Atributo | Tipo | Descripción |
|---|---|---|
| `idRemoto` | `Int32` | ID del backend (guardado al crear la mascota) |
| `nombre` | `String?` | Nombre de la mascota |
| `tipo` | `String?` | Nombre del tipo/especie |
| `apodos` | `String?` | Apodos |
| `alergias` | `String?` | Alergias |
| `uid` | `String?` | UID del dueño (para filtrar por usuario) |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `tableView` | `UITableView!` | Lista de mascotas |

### Flujo de carga
```
viewWillAppear()
        ↓
uid = UserDefaults.standard.string(forKey: "uid")
CoreDataManager.obtenerMascotasLocales(uid: uid)
        ↓
mascotas = [MascotaEntity]
tableView.reloadData()
```

### Flujo de navegación al detalle
```
tableView(didSelectRowAt: indexPath)
        ↓
vc = PerfilMascotaController
vc.mascota = mascotas[indexPath.row]   // MascotaEntity
navigationController?.pushViewController(vc)
```

### Eliminación con swipe
```
tableView(commit: .delete, forRowAt: indexPath)
        ↓
CoreDataManager.eliminarMascotaLocal(idRemoto: mascota.idRemoto)
mascotas.remove(at: indexPath.row)
tableView.deleteRows(...)
```

---

## PerfilMascotaController

### Descripción
Muestra el detalle de una mascota recibida por navegación y permite editar o eliminar el registro localmente en Core Data.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `Core Data` | Lee, actualiza y elimina `MascotaEntity` local |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/PerfilMascotaController.swift` | Lógica de la pantalla |
| `CoreData/CoreDataManager.swift` | `actualizarMascotaLocal()` / `eliminarMascotaLocal()` |

### Propiedad de entrada
```swift
var mascota: MascotaEntity?   // Recibida desde ListaMascotasController
```

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `txtNombre` | `UITextField` | Nombre (editable) |
| `lblTipo` | `UILabel` | Tipo/especie (solo lectura) |
| `txtApodos` | `UITextField` | Apodos (editable) |
| `txtAlergias` | `UITextField` | Alergias (editable) |

### Flujo de carga
```
viewDidLoad() → cargarDatos()
        ↓
Mapea MascotaEntity a los outlets:
  txtNombre   ← mascota.nombre
  lblTipo     ← mascota.tipo
  txtApodos   ← mascota.apodos
  txtAlergias ← mascota.alergias
```

### Flujo de guardado
```
btnGuardar()
        ↓
CoreDataManager.actualizarMascotaLocal(
    idRemoto: mascota.idRemoto,
    nombre:   txtNombre.text,
    apodos:   txtApodos.text,
    alergias: txtAlergias.text
)
        ↓
mostrarAlerta("Cambios guardados localmente.")
```

### Flujo de eliminación
```
btnEliminar()
        ↓
UIAlertController(Confirmar / Cancelar)
        ↓ Confirmar
CoreDataManager.eliminarMascotaLocal(idRemoto: mascota.idRemoto)
        ↓
navigationController?.popViewController()
→ ListaMascotasController (recarga en viewWillAppear)
```

---

## Flujo completo del módulo de mascotas

```
IngresarMascotaController
  ├── GET /api/tipos-mascota
  └── POST /api/mascotas
              ↓ éxito
        CoreDataManager.guardarMascotas()   ← persiste localmente

ListaMascotasController
  └── CoreDataManager.obtenerMascotasLocales(uid)   ← fuente única
              ↓
        [MascotaEntity] → tableView
              ↓ tap celda
        PerfilMascotaController   (push con MascotaEntity)
            ├── CoreDataManager.actualizarMascotaLocal()   (editar)
            └── CoreDataManager.eliminarMascotaLocal()     (eliminar)
                      ↓
                popViewController()
                → ListaMascotasController.viewWillAppear() → recarga
```

### Resumen de métodos CoreDataManager para mascotas
| Método | Operación |
|---|---|
| `guardarMascotas([MascotaDTO], uid:)` | Persiste mascotas al registrarlas desde `IngresarMascotaController` |
| `obtenerMascotasLocales(uid:)` | Fetch filtrado por uid |
| `eliminarMascotaLocal(idRemoto:)` | Borra por id |
| `actualizarMascotaLocal(idRemoto:nombre:apodos:alergias:)` | Edición local |
