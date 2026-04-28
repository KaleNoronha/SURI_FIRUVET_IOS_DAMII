# Módulo de Autenticación — Suri Firuvet 🐾

Documentación técnica de las pantallas de **registro** e **inicio de sesión**.

---

## RegistrarCuentaController

### Descripción
Registra un nuevo usuario usando Firebase Auth, guarda sus datos en Firestore y crea el cliente en la API REST.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `Firebase Auth` | Crea la cuenta con email y contraseña |
| `Firebase Firestore` | Guarda nombre, apellido, fecha, email y uid |
| `API REST` | Crea el registro de cliente en el backend |

### Archivos involucrados
| Archivo | Rol |
|---|---|
| `controller/RegistrarCuentaController.swift` | Lógica de la pantalla |
| `servicios/ClienteService.swift` | Llamada POST `/api/clientes` |
| `modelo/ClienteDTO.swift` | Modelo `ClienteRequest` |

### Outlets
| Outlet | Tipo | Descripción |
|---|---|---|
| `txtNombreCompleto` | `UITextField` | Nombre del usuario |
| `txtApellido` | `UITextField` | Apellido |
| `dpFechaNacimiento` | `UIDatePicker` | Fecha de nacimiento (máx: hoy) |
| `txtCorreoUsuario` | `UITextField` | Email |
| `txtContrasenia` | `UITextField` | Contraseña (secureEntry) |
| `txtRepetirContrasenia` | `UITextField` | Confirmación contraseña |
| `opAceptarTeryCon` | `UISwitch` | Aceptar términos y condiciones |

### Flujo de registro
```
Usuario llena formulario → btnCrearCuenta()
        ↓
Validaciones locales
  - Campos vacíos → mostrarAlerta()
  - Contraseñas no coinciden → mostrarAlerta()
  - Switch T&C apagado → mostrarAlerta()
        ↓ válido
Auth.auth().createUser(email, password)   [Firebase Auth]
        ↓ error                ↓ éxito → uid
mostrarAlerta(error)    Firestore: usuarios/{uid}.setData(
                            nombre, apellido, fechaNacimiento, email, uid
                        )
                               ↓ error          ↓ éxito
                        mostrarAlerta()   ClienteService.crearCliente(
                                              ClienteRequest(nombCli, apeCli, fecNac, uid)
                                          )   [POST /api/clientes]
                                               ↓
                                         mostrarAlerta("Cuenta creada")
                                               ↓
                                         dismiss() → pantalla login
```

### Colección Firestore
```
usuarios/{uid}
  ├── nombre:          String
  ├── apellido:        String
  ├── fechaNacimiento: String  (formato "dd/MM/yyyy")
  ├── email:           String
  └── uid:             String
```

### API — ClienteRequest
```swift
// POST https://suri-firuvet-ios-damii-api.onrender.com/api/clientes
struct ClienteRequest: Codable {
    let nombCli: String
    let apeCli:  String
    let fecNac:  String?
    let uid:     String
}
```

---

## ViewController (Login)

### Descripción
Pantalla inicial de inicio de sesión. Autentica al usuario con Firebase Auth, sincroniza el cliente con la API y guarda el `uid` en `UserDefaults`.

### Tecnologías
| Tecnología | Uso |
|---|---|
| `Firebase Auth` | Autentica con email y contraseña |
| `API REST` | Sincroniza/crea cliente en el backend |
| `UserDefaults` | Persiste `uid` para uso en toda la app |

### Flujo de inicio de sesión
```
Usuario ingresa email + contraseña → btnIniciarSesion()
        ↓
Auth.auth().signIn(email, password)   [Firebase Auth]
        ↓ error                ↓ éxito → uid
mostrarAlerta(error)    UserDefaults.set(uid, forKey: "uid")
                               ↓
                        ClienteService.sincronizarCliente(uid, nombre, apellido)
                          ├── buscarPorUid(uid)  [GET /api/clientes/uid/{uid}]
                          │     ↓ existe → retorna id
                          └── no existe → crearCliente()  [POST /api/clientes]
                               ↓
                        navegarA("MenuPrincipalController")
```

### Persistencia de sesión
```swift
// Guardado al login
UserDefaults.standard.set(uid, forKey: "uid")

// Leído en todos los controllers que consumen la API
let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
```
