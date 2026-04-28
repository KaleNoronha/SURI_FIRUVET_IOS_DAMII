# Módulo de Perfil Personal — Suri Firuvet 🐾

Documentación técnica de la pantalla **Perfil Personal**.

---

## PerfilPersonalController

### Descripción
Muestra y permite editar los datos del usuario autenticado. Lee y escribe directamente en Firestore usando el `uid` de Firebase Auth.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `Firebase Auth` | Obtiene el `uid` del usuario activo |
| `Firebase Firestore` | Lee y actualiza el documento `usuarios/{uid}` |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/PerfilPersonalController.swift` | Lógica de la pantalla |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `txtNombreCompleto` | `UITextField` | Nombre del usuario |
| `txtApellido` | `UITextField` | Apellido |
| `dpFechaNacimiento` | `UIDatePicker` | Fecha de nacimiento |
| `txtCorreoElectronico` | `UITextField` | Email (solo lectura) |
| `txtTelefono` | `UITextField` | Teléfono (editable) |

### Flujo de carga
```
viewDidLoad()
        ↓
Auth.auth().currentUser?.uid   [Firebase Auth]
        ↓ nil → no hace nada
        ↓ uid
Firestore: usuarios/{uid}.getDocument()
        ↓
Mapea campos al UI:
  nombre     → txtNombreCompleto
  apellido   → txtApellido
  email      → txtCorreoElectronico
  telefono   → txtTelefono
  fechaNacimiento (String "dd/MM/yyyy") → dpFechaNacimiento.date
```

### Flujo de guardado
```
btnGuardarCambios()
        ↓
Validación: nombre no vacío → mostrarAlerta() si falla
        ↓ válido
Firestore: usuarios/{uid}.updateData(
    nombre, fechaNacimiento, telefono, apellido
)
        ↓ error              ↓ éxito
mostrarAlerta(error)   mostrarAlerta("Perfil actualizado")
```

### Colección Firestore — campos actualizables
```
usuarios/{uid}
  ├── nombre:          String   ← editable
  ├── apellido:        String   ← editable
  ├── fechaNacimiento: String   ← editable (formato "dd/MM/yyyy")
  └── telefono:        String   ← editable
```
> `email` se muestra pero **no se actualiza** desde esta pantalla.

### Navegación
| Imagen tapped | Destino |
|---|---|
| `imgVolver` | `popViewController` / `dismiss` |
| `imgListaDeMascotas` | `ListaMascotasController` |
| `imgPerfilPersonal` | Sin acción (pantalla actual) |
