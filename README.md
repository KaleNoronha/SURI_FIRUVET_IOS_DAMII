# Suri Firuvet 🐾

Aplicación móvil iOS desarrollada en Swift para la gestión de servicios veterinarios. Permite a los dueños de mascotas registrarse, administrar el perfil de sus mascotas, agendar citas veterinarias, consultar lugares disponibles y acceder a beneficios exclusivos, todo desde su iPhone.

---

## Tecnologías utilizadas

- **Lenguaje:** Swift
- **Framework UI:** UIKit
- **Arquitectura:** MVC (Model - View - Controller)
- **Interfaz:** Storyboard (`Main.storyboard` + `LaunchScreen.storyboard`)
- **Plataforma:** iOS
- **IDE:** Xcode
- **Gestión de dependencias:** Ninguna (sin CocoaPods ni SPM)

---

## Arquitectura del proyecto

El proyecto sigue el patrón **MVC** y está organizado en las siguientes carpetas:

```
Suri Firuvet/
├── controller/       # ViewControllers de cada pantalla
├── modelo/           # Modelos de datos (entidades de la app)
├── estructuras/      # Estructuras Swift de soporte
├── protocolos/       # Protocolos e interfaces Swift
├── celdas/           # Celdas personalizadas para TableViews/CollectionViews
├── Assets.xcassets/  # Imágenes, íconos, banners y colores
└── Base.lproj/       # Storyboards (Main y LaunchScreen)
```

---

## Pantallas y funcionalidades

| Controller | Descripción |
|---|---|
| `RegistrarCuentaController` | Registro de nuevos usuarios en la plataforma |
| `MenuPrincipalController` | Menú principal con acceso a todas las funciones |
| `PerfilPersonalController` | Visualización y edición del perfil del usuario |
| `IngresarMascotaController` | Registro de una nueva mascota |
| `ListaMascotasController` | Lista de todas las mascotas registradas del usuario |
| `PerfilMascotaController` | Detalle y edición del perfil de una mascota específica |
| `CrearCitaController` | Formulario para agendar una nueva cita veterinaria |
| `ListaCitasController` | Lista de citas pendientes y pasadas |
| `DetallesCitaController` | Detalle completo de una cita específica |
| `ListaLugaresController` | Listado de clínicas o lugares veterinarios disponibles |
| `BeneficiosController` | Sección de beneficios y promociones para usuarios |
| `ConfiguracionController` | Ajustes y configuración de la cuenta |
| `TerminosCondicionesController` | Términos y condiciones de uso de la aplicación |

---

## Assets incluidos

La app cuenta con un sistema visual completo:

- **Banners** por pantalla: inicio de sesión, menú principal, crear cita, citas pendientes, perfil de mascota, perfil personal, beneficios, configuración
- **Botones personalizados:** crear cita, ingresar mascota, lista de citas, lista de lugares, beneficios, agregar
- **Íconos de opciones:** usuario, mascota, configuración, volver, eliminar
- **Fondo decorativo** con huellas (identidad visual de la marca)
- **Logo Firuvet** y **App Icon** configurados

---

## Requisitos para compilar

- macOS con Xcode instalado (se recomienda Xcode 14 o superior)
- iOS Deployment Target definido en el proyecto
- No requiere instalar dependencias externas

---

## Cómo clonar y abrir el proyecto

```bash
git clone https://github.com/tu-usuario/suri-firuvet.git
cd suri-firuvet
open "Suri Firuvet.xcodeproj"
```

Una vez abierto en Xcode, selecciona un simulador o dispositivo físico y presiona `Cmd + R` para compilar y ejecutar.

---

## Estructura de navegación

La navegación está definida completamente en `Main.storyboard` usando **Segues** de UIKit, siguiendo el flujo estándar de una app iOS con `UINavigationController`.

---

## Estado del proyecto

> Versión 3 — Proyecto en desarrollo. Las carpetas `modelo/`, `estructuras/`, `protocolos/` y `celdas/` están preparadas para escalar la arquitectura conforme se integre la lógica de negocio y conexión con servicios externos.
