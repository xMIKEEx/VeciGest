# 🏢 VeciGest

**Gestiona tu comunidad ahora más fácil que nunca**

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

</div>

## 📱 Descripción

VeciGest es una aplicación móvil multiplataforma desarrollada en Flutter que permite la gestión integral de comunidades de vecinos. La aplicación facilita la comunicación entre vecinos, la gestión de incidencias, documentos compartidos, encuestas y reservas de espacios comunes.

## ✨ Características Principales

### 🔐 Autenticación y Gestión de Usuarios
- **Registro/Login** con email y contraseña
- **Autenticación con Google** para mayor comodidad
- **Gestión de roles** (administrador/vecino)
- **Creación y gestión de comunidades**
- **Sistema de invitaciones** para nuevos vecinos

### 💬 Sistema de Chat
- **Hilos de conversación** organizados por temas
- **Mensajes en tiempo real** usando Firestore streams
- **Interfaz intuitiva** con burbujas de chat
- **Creación de nuevos hilos** de discusión

### 🚨 Gestión de Incidencias
- **Reportar incidencias** con descripción detallada
- **Adjuntar imágenes** para documentar problemas
- **Estados de seguimiento** (abierta, en progreso, cerrada)
- **Asignación de incidencias** a responsables
- **Historial completo** de incidencias

### 📄 Gestión de Documentos
- **Subida de documentos** (PDF, imágenes)
- **Organización por carpetas** temáticas
- **Almacenamiento seguro** en Firebase Storage
- **Acceso rápido** a documentos importantes

### 📊 Sistema de Encuestas
- **Creación de encuestas** con múltiples opciones
- **Votación en tiempo real**
- **Visualización de resultados**
- **Participación democrática** en decisiones comunitarias

### 📅 Reservas de Espacios Comunes
- **Reserva de recursos** (piscina, salón de actos, etc.)
- **Calendario integrado** para selección de fechas
- **Gestión de horarios** y disponibilidad
- **Historial de reservas**

### 🎨 Experiencia de Usuario
- **Diseño Material 3** moderno y limpio
- **Modo oscuro/claro** configurable
- **Interfaz intuitiva** y responsive
- **Navegación fluida** entre secciones
- **Feedback visual** con shimmer effects

## 🏗️ Arquitectura del Proyecto

### 📁 Estructura de Carpetas

```
lib/
├── data/
│   └── services/           # Servicios de datos y API
│       ├── auth_service.dart
│       ├── chat_service.dart
│       ├── incident_service.dart
│       ├── document_service.dart
│       ├── poll_service.dart
│       ├── reservation_service.dart
│       └── ...
├── domain/
│   └── models/            # Modelos de dominio
│       ├── user_model.dart
│       ├── incident_model.dart
│       ├── message_model.dart
│       ├── document_model.dart
│       └── ...
├── presentation/          # Capa de presentación
│   ├── auth/             # Autenticación
│   ├── chat/             # Sistema de chat
│   ├── incidents/        # Gestión de incidencias
│   ├── documents/        # Gestión de documentos
│   ├── polls/            # Sistema de encuestas
│   ├── reservations/     # Reservas
│   └── home/             # Pantalla principal
└── utils/                # Utilidades
    ├── constants.dart    # Constantes globales
    ├── routes.dart       # Configuración de rutas
    └── theme.dart        # Temas de la aplicación
```

### 🔧 Patrones de Arquitectura

- **Clean Architecture**: Separación clara entre capas de datos, dominio y presentación
- **Provider Pattern**: Gestión de estado reactiva
- **Repository Pattern**: Abstracción de fuentes de datos
- **Service Layer**: Lógica de negocio encapsulada
- **Model-View-Controller**: Separación de responsabilidades

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter 3.7.2+**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **Material 3**: Sistema de diseño moderno

### Backend y Servicios
- **Firebase Authentication**: Gestión de usuarios
- **Cloud Firestore**: Base de datos NoSQL en tiempo real
- **Firebase Storage**: Almacenamiento de archivos
- **Google Sign-In**: Autenticación con Google

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.3
  cloud_firestore: ^5.6.7
  firebase_storage: ^12.4.5
  
  # Gestión de estado
  provider: ^6.1.2
  
  # UI/UX
  shimmer: ^3.0.0
  timeago: ^3.6.1
  
  # Funcionalidades
  image_picker: ^1.1.2
  file_picker: ^10.1.5
  url_launcher: ^6.3.0
  google_sign_in: ^6.2.1
  
  # Internacionalización
  intl: ^0.19.0
  
  # Utilidades
  equatable: ^2.0.5
```

## 🚀 Configuración e Instalación

### Prerrequisitos

1. **Flutter SDK** (3.7.2 o superior)
2. **Dart SDK** (incluido con Flutter)
3. **Android Studio/VS Code** con plugins de Flutter
4. **Proyecto Firebase** configurado
5. **Git** para control de versiones

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/vecigest.git
   cd vecigest
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   - Crear proyecto en [Firebase Console](https://console.firebase.google.com)
   - Habilitar Authentication (Email/Password y Google)
   - Crear base de datos Firestore
   - Configurar Firebase Storage
   - Descargar archivos de configuración:
     - `android/app/google-services.json` para Android
     - `ios/Runner/GoogleService-Info.plist` para iOS

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Configuración de Firebase

#### Android
1. Añadir `google-services.json` en `android/app/`
2. Configurar `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

#### iOS
1. Añadir `GoogleService-Info.plist` en `ios/Runner/`
2. Configurar URL Schemes en Info.plist

## 🎯 Uso de la Aplicación

### Para Administradores

1. **Registro como Administrador**
   - Crear cuenta con email/contraseña o Google
   - Configurar nueva comunidad
   - Gestionar invitaciones para vecinos

2. **Gestión de la Comunidad**
   - Supervisar incidencias reportadas
   - Moderar hilos de chat
   - Gestionar documentos importantes
   - Crear encuestas para decisiones comunitarias

### Para Vecinos

1. **Registro por Invitación**
   - Recibir invitación del administrador
   - Completar registro con código de invitación

2. **Participación en la Comunidad**
   - Participar en chats comunitarios
   - Reportar incidencias
   - Votar en encuestas
   - Realizar reservas de espacios

## 📱 Capturas de Pantalla

### Autenticación
- Pantalla de bienvenida con opciones de registro/login
- Formularios de registro con validación
- Integración con Google Sign-In

### Dashboard Principal
- Vista de módulos organizados en tarjetas
- Acceso rápido a todas las funcionalidades
- Perfil de usuario y configuración

### Chat Comunitario
- Lista de hilos de conversación
- Interfaz de chat en tiempo real
- Creación de nuevos temas

### Gestión de Incidencias
- Lista de incidencias con filtros
- Formulario de reporte con imágenes
- Seguimiento de estados

## 🔒 Seguridad y Privacidad

### Medidas de Seguridad
- **Autenticación segura** con Firebase Auth
- **Reglas de seguridad** en Firestore
- **Validación de datos** en cliente y servidor
- **Encriptación** de datos en tránsito

### Gestión de Permisos
- **Sistema de roles** (administrador/vecino)
- **Control de acceso** por funcionalidades
- **Validación de pertenencia** a comunidad

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/
```

### Usuario de Prueba
```dart
Email: tester@vecigest.com
Contraseña: tester1234
```

## 📦 Build y Distribución

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# AAB para Play Store
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## 🤝 Contribución

### Guidelines para Contribuir

1. **Fork** el repositorio
2. **Crear una rama** para la nueva funcionalidad
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
3. **Hacer commits** descriptivos
4. **Crear Pull Request** con descripción detallada

### Estándares de Código
- Seguir las convenciones de Dart/Flutter
- Documentar funciones públicas
- Escribir tests para nuevas funcionalidades
- Mantener la arquitectura limpia

## 📋 Roadmap

### Versión 1.1
- [ ] Notificaciones push
- [ ] Chat privado entre vecinos
- [ ] Calendario de eventos comunitarios
- [ ] Exportación de reportes

### Versión 1.2
- [ ] Integración con sistemas de pago
- [ ] Gestión de gastos comunitarios
- [ ] Módulo de mantenimiento
- [ ] App para administración web

### Versión 2.0
- [ ] Versión web completa
- [ ] API REST pública
- [ ] Integraciones con terceros
- [ ] Analytics avanzados

## 🐛 Problemas Conocidos

- **Firebase Auth**: Configurar correctamente Google Sign-In para producción
- **iOS Build**: Verificar certificados y perfiles de provisioning
- **Web Support**: Firebase Storage puede requerir configuración CORS

## 📞 Soporte

### Reportar Bugs
- Usar GitHub Issues para reportar problemas
- Incluir logs y pasos para reproducir
- Especificar versión de Flutter y dispositivo

### Contacto
- **Email**: soporte@vecigest.com
- **Documentación**: [Wiki del proyecto](https://github.com/tu-usuario/vecigest/wiki)

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- **Flutter Team** por el excelente framework
- **Firebase** por los servicios backend
- **Material Design** por las guidelines de UI
- **Comunidad de desarrolladores** por las librerías utilizadas

---

<div align="center">

**Desarrollado con ❤️ para la gestión de comunidades**

[⬆ Volver arriba](#-vecigest)

</div>
