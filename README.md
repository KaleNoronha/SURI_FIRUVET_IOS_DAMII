# Suri Firuvet 🐾

Aplicación móvil iOS desarrollada en Swift para la gestión de servicios veterinarios. Permite a los dueños de mascotas registrarse, administrar el perfil de sus mascotas, agendar citas veterinarias y consultar clínicas disponibles.

---

## Tecnologías utilizadas

- **Lenguaje:** Swift
- **Framework UI:** UIKit
- **Arquitectura:** MVC (Model - View - Controller)
- **Interfaz:** Storyboard (`Main.storyboard` + `LaunchScreen.storyboard`)
- **Plataforma:** iOS
- **IDE:** Xcode 14+
- **Autenticación:** Firebase Auth
- **Base de datos en la nube:** Firebase Firestore
- **Persistencia local:** Core Data (`SuriFiruvet.xcdatamodeld`)
- **API REST:** `https://suri-firuvet-ios-damii-api.onrender.com/api`
- **Sesión:** `UserDefaults` (almacena `uid` del usuario autenticado)

---

## Arquitectura del proyecto

```
SURI_FIRUVET_IOS_DAMII/
├── docs/                     # Documentación técnica por módulo
├── Suri Firuvet/
│   ├── controller/           # ViewControllers de cada pantalla
│   ├── modelo/               # DTOs y structs de request/response
│   ├── servicios/            # Clientes HTTP (URLSession) por entidad
│   ├── CoreData/             # CoreDataManager + modelo .xcdatamodeld
│   ├── Cells/                # Celdas personalizadas para TableViews
│   ├── Assets.xcassets/      # Imágenes, íconos, banners y colores
│   └── Base.lproj/           # Main.storyboard + LaunchScreen.storyboard
└── README.md
```

---

## Pantallas y fuente de datos

| Controller | Descripción | Firebase Auth | Firestore | API REST | Core Data |
|---|---|:---:|:---:|:---:|:---:|
| `ViewController` | Inicio de sesión | ✅ | | ✅ | |
| `RegistrarCuentaController` | Registro de usuario | ✅ | ✅ | ✅ | |
| `MenuPrincipalController` | Dashboard de navegación | | | | |
| `PerfilPersonalController` | Ver y editar perfil del usuario | ✅ | ✅ | | |
| `IngresarMascotaController` | Registrar nueva mascota | | | ✅ | ✅ |
| `ListaMascotasController` | Lista de mascotas del usuario | | | | ✅ |
| `PerfilMascotaController` | Detalle y edición de mascota | | | | ✅ |
| `CrearCitaController` | Agendar nueva cita veterinaria | | | ✅ | |
| `ListaCitasController` | Lista de citas del usuario | | | ✅ | |
| `DetallesCitaController` | Detalle, modificar y eliminar cita | | | ✅ | |

---

## Flujo de navegación

```
ViewController (Login)
  ├── Firebase Auth → signIn
  ├── API → sincronizarCliente(uid)
  └── UserDefaults.set(uid)
          ↓
  MenuPrincipalController
    ├──→ IngresarMascotaController
    │       ├── GET /api/tipos-mascota
    │       ├── POST /api/mascotas
    │       └── CoreData.guardarMascotas()
    │
    ├──→ ListaMascotasController
    │       ├── CoreData.obtenerMascotasLocales(uid)
    │       └──→ PerfilMascotaController
    │               ├── CoreData.actualizarMascotaLocal()
    │               └── CoreData.eliminarMascotaLocal()
    │
    ├──→ CrearCitaController
    │       ├── GET /api/mascotas?uid
    │       ├── GET /api/clinicas
    │       ├── GET /api/tipos-cita
    │       └── POST /api/citas
    │
    ├──→ ListaCitasController
    │       ├── GET /api/citas?uid
    │       └──→ DetallesCitaController
    │               ├── PUT  /api/citas/{id}
    │               └── DELETE /api/citas/{id}
    │
    └──→ PerfilPersonalController
            ├── Firestore: usuarios/{uid}.getDocument()
            └── Firestore: usuarios/{uid}.updateData()
```

---

## Firestore — Estructura de datos

```
usuarios/{uid}
  ├── nombre, apellido, fechaNacimiento, email, uid, telefono
  └── citas/{citaId}
        ├── mascota, fechaHora, lugar, tipo, comentario
```

> `CoreDataManager` gestiona la subcolección `citas` en Firestore además de la entidad `MascotaEntity` en Core Data local.

---

## Core Data — Entidades

| Entidad | Atributos |
|---|---|
| `CitaEntity` | `mascota`, `fechaHora`, `lugar`, `tipo`, `comentario` |
| `MascotaEntity` | `idRemoto`, `nombre`, `tipo`, `apodos`, `alergias`, `uid` |

---

## API REST — Endpoints

| Método | Endpoint | Usado en |
|---|---|---|
| POST | `/api/clientes` | Registro y login |
| GET | `/api/clientes/uid/{uid}` | Login |
| GET | `/api/tipos-mascota` | Ingresar mascota |
| POST | `/api/mascotas` | Ingresar mascota |
| GET | `/api/clinicas` | Crear cita |
| GET | `/api/tipos-cita` | Crear cita |
| POST | `/api/citas` | Crear cita |
| GET | `/api/citas?uid={uid}` | Lista de citas |
| PUT | `/api/citas/{id}` | Detalles de cita |
| DELETE | `/api/citas/{id}?uid={uid}` | Detalles de cita |

---

## Requisitos para compilar

- macOS con Xcode 14 o superior
- Firebase configurado (`GoogleService-Info.plist` incluido)
- iOS Deployment Target definido en el proyecto
- No requiere CocoaPods ni SPM

---

## Cómo clonar y abrir el proyecto

```bash
git clone https://github.com/tu-usuario/suri-firuvet.git
cd suri-firuvet
open "Suri Firuvet.xcodeproj"
```

Selecciona un simulador o dispositivo físico y presiona `Cmd + R` para compilar y ejecutar.

---

## Documentación técnica

La carpeta `docs/` contiene documentación detallada por módulo:

| Archivo | Contenido |
|---|---|
| [`docs/index.md`](docs/index.md) | Índice general y resumen de tecnologías |
| [`docs/autenticacion.md`](docs/autenticacion.md) | Login y registro |
| [`docs/perfil_personal.md`](docs/perfil_personal.md) | Perfil del usuario |
| [`docs/mascotas.md`](docs/mascotas.md) | Gestión de mascotas |
| [`docs/citas.md`](docs/citas.md) | Gestión de citas |

---

## Estado del proyecto

> Versión 3 — En desarrollo activo. Autenticación, perfil, mascotas y citas implementados. Módulos de beneficios, configuración y términos pendientes.
