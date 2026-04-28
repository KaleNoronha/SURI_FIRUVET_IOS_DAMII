# Documentación Técnica — Suri Firuvet 🐾

Índice de la documentación por módulo.

---

## Archivos de documentación

| Archivo | Módulo | Controllers |
|---|---|---|
| [`autenticacion.md`](./autenticacion.md) | Login y Registro | `ViewController`, `RegistrarCuentaController` |
| [`perfil_personal.md`](./perfil_personal.md) | Perfil de usuario | `PerfilPersonalController` |
| [`mascotas.md`](./mascotas.md) | Gestión de mascotas | `IngresarMascotaController`, `ListaMascotasController`, `PerfilMascotaController` |
| [`citas.md`](./citas.md) | Gestión de citas | `CrearCitaController`, `ListaCitasController`, `DetallesCitaController` |

---

## Resumen de tecnologías por pantalla

| Controller | Firebase Auth | Firestore | API REST | UserDefaults | Core Data |
|---|:---:|:---:|:---:|:---:|:---:|
| `ViewController` (Login) | ✅ | | ✅ | ✅ (escribe uid) | |
| `RegistrarCuentaController` | ✅ | ✅ (escribe) | ✅ POST cliente | | |
| `PerfilPersonalController` | ✅ (lee uid) | ✅ (lee/escribe) | | | |
| `IngresarMascotaController` | | | ✅ GET tipos, POST mascota | ✅ (lee uid) | |
| `ListaMascotasController` | | | | ✅ (lee uid) | ✅ fuente única |
| `PerfilMascotaController` | | | | | ✅ editar/eliminar |
| `CrearCitaController` | | | ✅ GET mascotas/clínicas/tipos, POST cita | ✅ (lee uid) | |
| `ListaCitasController` | | | ✅ GET citas | ✅ (lee uid) | |
| `DetallesCitaController` | | | ✅ PUT/DELETE cita | ✅ (lee uid) | |

---

## API Base URL

```
https://suri-firuvet-ios-damii-api.onrender.com/api
```

| Endpoint | Método | Usado en |
|---|---|---|
| `/clientes` | POST | `RegistrarCuentaController`, `ViewController` |
| `/clientes/uid/{uid}` | GET | `ViewController` |
| `/mascotas?uid={uid}` | GET | `CrearCitaController` |
| `/mascotas` | POST | `IngresarMascotaController` |
| `/clinicas` | GET | `CrearCitaController` |
| `/tipos-cita` | GET | `CrearCitaController` |
| `/tipos-mascota` | GET | `IngresarMascotaController` |
| `/citas?uid={uid}` | GET | `ListaCitasController` |
| `/citas` | POST | `CrearCitaController` |
| `/citas/{id}` | PUT | `DetallesCitaController` |
| `/citas/{id}?uid={uid}` | DELETE | `DetallesCitaController` |

---

## Firestore — Colecciones

```
usuarios/{uid}
  ├── nombre, apellido, fechaNacimiento, email, uid, telefono
  └── citas/{citaId}          ← gestionado por CoreDataManager
        ├── mascota, fechaHora, lugar, tipo, comentario
```

> `CoreDataManager` usa Firestore internamente a pesar de su nombre. El modelo Core Data local (`CitaEntity`) está definido pero no se usa en los controllers actuales.

---

## Flujo de navegación general

```
ViewController (Login)
        ↓
MenuPrincipalController
    ├──→ CrearCitaController
    ├──→ ListaCitasController ──→ DetallesCitaController
    ├──→ IngresarMascotaController
    ├──→ ListaMascotasController ──→ PerfilMascotaController
    └──→ PerfilPersonalController
```
