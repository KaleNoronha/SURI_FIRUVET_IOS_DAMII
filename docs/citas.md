# Módulo de Citas — Suri Firuvet 🐾

Documentación técnica de las pantallas **Crear Cita**, **Lista de Citas** y **Detalles de Cita**.

---

## CrearCitaController

### Descripción
Formulario para registrar una nueva cita veterinaria. Carga mascotas, clínicas y tipos de cita desde la API, y envía el registro al backend.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `API REST` | GET mascotas, clínicas, tipos de cita / POST nueva cita |
| `UserDefaults` | Lee el `uid` del usuario activo |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/CrearCitaController.swift` | Lógica de la pantalla |
| `servicios/CitaService.swift` | POST `/api/citas` |
| `servicios/MascotaService.swift` | GET `/api/mascotas?uid={uid}` |
| `servicios/ClinicaService.swift` | GET `/api/clinicas` |
| `servicios/TipoCitaService.swift` | GET `/api/tipos-cita` |
| `modelo/CitaDTO.swift` | `CrearCitaRequest` |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `pvMascota` | `UIPickerView?` | Selector de mascota del usuario |
| `pvLugar` | `UIPickerView?` | Selector de clínica |
| `pvTipo` | `UIPickerView?` | Selector de tipo de cita |
| `dpFechaHora` | `UIDatePicker?` | Fecha y hora (modo `.dateAndTime`) |
| `txtComentario` | `UITextField!` | Comentario opcional |

### Flujo de carga de datos
```
viewDidLoad() → cargarDatos()
        ↓
┌─────────────────────────────────────────────────────┐
│ MascotaService.listarMascotas(uid)                  │
│   [GET /api/mascotas?uid={uid}]                     │
│   → mascotas = [MascotaDTO] → pvMascota.reload()    │
├─────────────────────────────────────────────────────┤
│ ClinicaService.listarClinicas()                     │
│   [GET /api/clinicas]                               │
│   → clinicas = [ClinicaDTO] → pvLugar.reload()      │
├─────────────────────────────────────────────────────┤
│ TipoCitaService.listarTipos()                       │
│   [GET /api/tipos-cita]                             │
│   → tiposCita = [TipoCitaDTO] → pvTipo.reload()     │
└─────────────────────────────────────────────────────┘
```
> Las 3 llamadas se ejecutan en paralelo (no hay dependencia entre ellas).

### Flujo de registro
```
btnRegistrar()
        ↓
Validación: mascotas, clinicas, tiposCita no vacíos → mostrarMensaje("Error") si falla
        ↓ válido
uid = UserDefaults.standard.string(forKey: "uid")
fecha = DateFormatter("yyyy-MM-dd'T'HH:mm:ss").string(from: dpFechaHora.date)

CitaService.crearCita(CrearCitaRequest(
    uid, idTipoCita, fecha, comentario?, idMascota, idClinica
))   [POST /api/citas]
        ↓ error                  ↓ éxito
mostrarMensaje("Error")    mostrarMensaje("Cita registrada")
                                 ↓
                           limpiarCampos()
```

### API — Endpoints usados
```
GET  /api/mascotas?uid={uid}     → [MascotaDTO]
GET  /api/clinicas               → [ClinicaDTO]
GET  /api/tipos-cita             → [TipoCitaDTO]
POST /api/citas                  → CitaDTO
     Body: { uid, idTipoCita, fecha, comentario?, idMascota, idClinica }
```

---

## ListaCitasController

### Descripción
Lista todas las citas del usuario en un `UITableView`. Al tocar una celda navega a `DetallesCitaController` pasando el `CitaDTO`.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `API REST` | GET citas del usuario |
| `UserDefaults` | Lee el `uid` del usuario activo |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/ListaCitasController.swift` | Lógica de la pantalla |
| `servicios/CitaService.swift` | GET `/api/citas?uid={uid}` |
| `modelo/CitaDTO.swift` | Modelo de datos |
| `Cells/CitaTableViewCell.swift` | Celda personalizada |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `tableView` | `UITableView!` | Lista de citas |

### Flujo de carga
```
viewWillAppear() → cargarCitas()
        ↓
uid = UserDefaults.standard.string(forKey: "uid")
CitaService.listarCitas(uid: uid)   [GET /api/citas?uid={uid}]
        ↓ error                  ↓ éxito
mostrarMensaje(error)      citas = [CitaDTO]
                           tableView.reloadData()
```

### Celda — CitaTableViewCell
| Label | Fuente |
|---|---|
| `lblMascota` | `cita.nombreMascota ?? "Mascota"` |
| `lblFechaHora` | `"Fecha: \(cita.fecha ?? "")"` |

### Flujo de navegación al detalle
```
tableView(didSelectRowAt: indexPath)
        ↓
performSegue("irDetalleCita", sender: indexPath.row)
        ↓
prepare(for segue:)
  destino.cita = citas[index]   // CitaDTO completo
        ↓
DetallesCitaController
```

---

## DetallesCitaController

### Descripción
Muestra el detalle completo de una cita y permite **modificar** el comentario o **eliminar** la cita mediante la API REST.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `API REST` | PUT modificar cita / DELETE eliminar cita |
| `UserDefaults` | Lee el `uid` del usuario activo |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/DetallesCitaController.swift` | Lógica de la pantalla |
| `servicios/CitaService.swift` | PUT `/api/citas/{id}` / DELETE `/api/citas/{id}` |
| `modelo/CitaDTO.swift` | `CitaDTO` y `CrearCitaRequest` |

### Propiedad de entrada
```swift
var cita: CitaDTO?   // Recibida desde ListaCitasController vía segue
```

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `lblMascota` | `UILabel` | Nombre de la mascota |
| `lblFechaHora` | `UILabel` | Fecha y hora de la cita |
| `lblLugar` | `UILabel` | Nombre de la clínica |
| `lblTipo` | `UILabel` | Tipo de cita |
| `lblComentario` | `UILabel` | Comentario |

### Flujo de carga
```
viewDidLoad() → cargarDatos()
        ↓
Mapea cita (CitaDTO) a los labels:
  lblMascota    ← cita.nombreMascota
  lblFechaHora  ← cita.fecha
  lblLugar      ← cita.nombreClinica
  lblTipo       ← cita.nombreTipoCita
  lblComentario ← cita.comentario
```

### Flujo de eliminación
```
btnEliminarCita()
        ↓
UIAlertController(Confirmar / Cancelar)
        ↓ Confirmar
uid = UserDefaults.standard.string(forKey: "uid")
CitaService.eliminarCita(id: cita.idCita, uid: uid)
  [DELETE /api/citas/{id}?uid={uid}]
        ↓ error                  ↓ éxito
mostrarMensaje(error)      mostrarMensaje("Cita eliminada")
                                 ↓
                           navigationController?.popViewController()
```

### Flujo de modificación
```
btnModificarCita()
        ↓
UIAlertController con UITextField (comentario actual precargado)
        ↓ Guardar
CitaService.modificarCita(id: cita.idCita, CrearCitaRequest(
    uid, idTipoCita, fecha, nuevoComentario, idMascota, idClinica
))   [PUT /api/citas/{id}]
        ↓ error                  ↓ éxito
mostrarMensaje(error)      self.cita = citaActualizada
                           cargarDatos()   // refresca UI
                           mostrarMensaje("Cita modificada")
```

### API — Endpoints usados
```
PUT    /api/citas/{id}           → CitaDTO actualizado
       Body: { uid, idTipoCita, fecha, comentario?, idMascota, idClinica }
DELETE /api/citas/{id}?uid={uid} → 200 OK
```

---

## Flujo completo del módulo de citas

```
MenuPrincipalController
    │
    ├──→ CrearCitaController
    │         │
    │         ├── GET /api/mascotas?uid={uid}
    │         ├── GET /api/clinicas
    │         ├── GET /api/tipos-cita
    │         └── POST /api/citas  ──────────────────────────────┐
    │                                                             │
    └──→ ListaCitasController                                     │
              │                                                   │
              ├── GET /api/citas?uid={uid}  ←────────────────────┘
              │         ↓
              │    [CitaDTO] → tableView
              │
              └──→ DetallesCitaController  (segue "irDetalleCita")
                        │
                        ├── PUT  /api/citas/{id}   (modificar)
                        └── DELETE /api/citas/{id} (eliminar)
                                   ↓
                             popViewController()
                             → ListaCitasController
```

### CoreDataManager — nota de arquitectura
`CoreDataManager.swift` está nombrado como Core Data pero **actualmente opera sobre Firestore**, no sobre el stack de Core Data local. El modelo `CitaEntity` en `SuriFiruvet.xcdatamodeld` está definido pero no se usa en los controllers actuales.

| Método | Operación real |
|---|---|
| `insertarCita(uid:...)` | `Firestore: usuarios/{uid}/citas.addDocument()` |
| `obtenerCitas(uid:...)` | `Firestore: usuarios/{uid}/citas.getDocuments()` |
| `eliminarCita(uid:citaId:)` | `Firestore: usuarios/{uid}/citas/{id}.delete()` |
