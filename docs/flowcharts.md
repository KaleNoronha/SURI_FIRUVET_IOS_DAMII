# Diagramas Mermaid — Suri Firuvet 🐾

---

## Navegación general

```mermaid
flowchart TD
    VC[ViewController\nLogin]
    MENU[MenuPrincipalController]
    REG[RegistrarCuentaController]
    INMAS[IngresarMascotaController]
    LMAS[ListaMascotasController]
    PMAS[PerfilMascotaController]
    CCITA[CrearCitaController]
    LCITA[ListaCitasController]
    DCITA[DetallesCitaController]
    PERF[PerfilPersonalController]

    VC -->|segue irMenuPrincipal| MENU
    VC -->|segue irRegistrarCuenta| REG
    REG -->|dismiss| VC
    MENU --> INMAS
    MENU --> LMAS
    MENU --> CCITA
    MENU --> LCITA
    MENU --> PERF
    LMAS --> PMAS
    LCITA -->|segue irDetalleCita| DCITA
```

---

## Login — ViewController

```mermaid
flowchart TD
    A([Usuario ingresa email y contraseña]) --> B[btnIniciarSesion]
    B --> C[Firebase Auth\nsignIn]
    C -->|error| D[mostrarAlerta error]
    C -->|éxito uid| E[UserDefaults.set uid]
    E --> F[ClienteService\nbuscarPorUid\nGET /api/clientes/uid/uid]
    F -->|existe| G[retorna id]
    F -->|no existe| H[ClienteService\ncrearCliente\nPOST /api/clientes]
    G --> I[navegarA MenuPrincipalController]
    H --> I
```

---

## Registro — RegistrarCuentaController

```mermaid
flowchart TD
    A([Usuario llena formulario]) --> B[btnCrearCuenta]
    B --> C{Validaciones}
    C -->|campos vacíos| D[mostrarAlerta]
    C -->|contraseñas no coinciden| D
    C -->|T&C apagado| D
    C -->|válido| E[Firebase Auth\ncreateUser email password]
    E -->|error| F[mostrarAlerta error]
    E -->|éxito uid| G[Firestore\nusuarios/uid .setData\nnombre apellido fechaNacimiento email uid]
    G -->|error| H[mostrarAlerta error]
    G -->|éxito| I[ClienteService\ncrearCliente\nPOST /api/clientes]
    I --> J[mostrarAlerta Cuenta creada]
    J --> K[dismiss → ViewController]
```

---

## Perfil Personal — PerfilPersonalController

```mermaid
flowchart TD
    A([viewDidLoad]) --> B[Firebase Auth\ncurrentUser uid]
    B -->|nil| C([no hace nada])
    B -->|uid| D[Firestore\nusuarios/uid .getDocument]
    D --> E[Mapea campos al UI\nnombre apellido email telefono fecha]

    F([btnGuardarCambios]) --> G{nombre vacío?}
    G -->|sí| H[mostrarAlerta]
    G -->|no| I[Firestore\nusuarios/uid .updateData\nnombre apellido fechaNacimiento telefono]
    I -->|error| J[mostrarAlerta error]
    I -->|éxito| K[mostrarAlerta Perfil actualizado]
```

---

## Mascotas — IngresarMascotaController

```mermaid
flowchart TD
    A([viewDidLoad]) --> B[TipoMascotaService\nlistarTipos\nGET /api/tipos-mascota]
    B -->|éxito| C[tiposMascota = lista\npickerEspecie.reload\ntxtEspecie = primero]
    B -->|error| D([picker vacío])

    E([btnRegistrarMascota]) --> F{Validaciones}
    F -->|nombre vacío| G[mostrarAlerta]
    F -->|tipos vacíos| G
    F -->|uid vacío| G
    F -->|válido| H[MascotaService\ncrearMascota\nPOST /api/mascotas]
    H -->|error| I[mostrarAlerta error]
    H -->|éxito MascotaDTO| J[CoreDataManager\nguardarMascotas]
    J --> K[mostrarAlerta Mascota registrada]
    K --> L[limpiarCampos]
```

---

## Mascotas — ListaMascotasController

```mermaid
flowchart TD
    A([viewWillAppear]) --> B[CoreDataManager\nobtenerMascotasLocales uid]
    B --> C[mascotas = MascotaEntity\ntableView.reloadData]

    D([tap celda]) --> E[PerfilMascotaController\nvc.mascota = MascotaEntity\npushViewController]

    F([swipe eliminar]) --> G[CoreDataManager\neliminarMascotaLocal idRemoto]
    G --> H[mascotas.remove\ntableView.deleteRows]
```

---

## Mascotas — PerfilMascotaController

```mermaid
flowchart TD
    A([viewDidLoad]) --> B[cargarDatos\nMapea MascotaEntity al UI\nnombre especie apodos alergias]

    C([btnGuardar]) --> D[CoreDataManager\nactualizarMascotaLocal\nidRemoto nombre apodos alergias]
    D --> E[mostrarAlerta Cambios guardados]

    F([btnEliminar]) --> G[UIAlertController\nConfirmar / Cancelar]
    G -->|Cancelar| H([no hace nada])
    G -->|Confirmar| I[CoreDataManager\neliminarMascotaLocal idRemoto]
    I --> J[popViewController\n→ ListaMascotasController]
```

---

## Citas — CrearCitaController

```mermaid
flowchart TD
    A([viewDidLoad]) --> B[cargarDatos]
    B --> C[MascotaService\nlistarMascotas uid\nGET /api/mascotas?uid]
    B --> D[ClinicaService\nlistarClinicas\nGET /api/clinicas]
    B --> E[TipoCitaService\nlistarTipos\nGET /api/tipos-cita]
    C --> F[pvMascota.reload]
    D --> G[pvLugar.reload]
    E --> H[pvTipo.reload]

    I([btnRegistrar]) --> J{mascotas clinicas\ntipos no vacíos?}
    J -->|no| K[mostrarMensaje Error]
    J -->|sí| L[CitaService\ncrearCita\nPOST /api/citas]
    L -->|error| M[mostrarMensaje error]
    L -->|éxito| N[mostrarMensaje Cita registrada]
    N --> O[limpiarCampos]
```

---

## Citas — ListaCitasController

```mermaid
flowchart TD
    A([viewWillAppear]) --> B[CitaService\nlistarCitas uid\nGET /api/citas?uid]
    B -->|error| C[mostrarMensaje error]
    B -->|éxito| D[citas = CitaDTO\ntableView.reloadData]

    E([tap celda]) --> F[performSegue irDetalleCita\nsender: indexPath.row]
    F --> G[prepare for segue\ndestino.cita = citas index]
    G --> H[DetallesCitaController]
```

---

## Citas — DetallesCitaController

```mermaid
flowchart TD
    A([viewDidLoad]) --> B[cargarDatos\nMapea CitaDTO a labels\nmascota fecha lugar tipo comentario]

    C([btnEliminarCita]) --> D[UIAlertController\nConfirmar / Cancelar]
    D -->|Cancelar| E([no hace nada])
    D -->|Confirmar| F[CitaService\neliminarCita id uid\nDELETE /api/citas/id?uid]
    F -->|error| G[mostrarMensaje error]
    F -->|éxito| H[mostrarMensaje Cita eliminada]
    H --> I[popViewController\n→ ListaCitasController]

    J([btnModificarCita]) --> K[UIAlertController\nUITextField comentario precargado]
    K -->|Cancelar| L([no hace nada])
    K -->|Guardar| M[CitaService\nmodificarCita id\nPUT /api/citas/id]
    M -->|error| N[mostrarMensaje error]
    M -->|éxito CitaDTO| O[self.cita = citaActualizada\ncargarDatos\nmostrarMensaje Cita modificada]
```
