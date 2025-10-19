# 🏪 Sistema de Inventario y Ventas

Un sistema completo de gestión de inventario y ventas desarrollado en Flutter con arquitectura limpia, implementando patrones de diseño modernos y tecnologías robustas.

## 🚀 Características Principales

- **Gestión de Usuarios**: Sistema de autenticación con roles (Admin/Empleado)
- **Control de Inventario**: Gestión completa de productos y stock
- **Gestión de Sucursales**: Administración de múltiples ubicaciones
- **Sistema de Ventas**: Procesamiento de ventas y facturación
- **Gestión de Empleados**: Administración del personal por sucursal
- **Interfaz Responsiva**: Diseño moderno con Material Design 3

## 🏗️ Arquitectura del Proyecto

Este proyecto implementa una **Arquitectura Limpia (Clean Architecture)** con separación clara de responsabilidades:

```
lib/
├── core/                    # Capa de infraestructura central
│   ├── app_bloc/           # Estado global de la aplicación
│   └── routes/             # Configuración de navegación
├── data/                   # Capa de datos
│   ├── models/            # Modelos de datos (Product, Sale, User, etc.)
│   └── services/          # Servicios de datos (Firebase, APIs)
└── presentation/           # Capa de presentación
    ├── modules/           # Lógica de negocio (BLoC/Cubit)
    └── screens/           # Interfaces de usuario
```

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter 3.7.2** - Framework de desarrollo multiplataforma
- **Material Design 3** - Sistema de diseño moderno
- **Flutter Bloc 9.0.0** - Gestión de estado reactiva

### Backend & Servicios
- **Firebase Core 4.1.0** - Plataforma de desarrollo
- **Cloud Firestore 6.0.1** - Base de datos NoSQL
- **Firebase Auth 6.1.1** - Autenticación de usuarios

### Patrones de Diseño
- **BLoC Pattern** - Gestión de estado con separación de lógica
- **Repository Pattern** - Abstracción de acceso a datos
- **Service Layer** - Encapsulación de lógica de negocio
- **Clean Architecture** - Separación de capas y responsabilidades

## 📱 Funcionalidades Implementadas

### 🔐 Autenticación y Autorización
- Login seguro con Firebase Auth
- Gestión de roles (Administrador/Empleado)
- Control de acceso basado en permisos
- Estado de sesión persistente

### 📦 Gestión de Inventario
- **Productos**: CRUD completo de productos
- **Stock**: Control de inventario por sucursal
- **Categorías**: Organización de productos
- **Alertas**: Notificaciones de stock bajo

### 🏢 Gestión de Sucursales
- **Múltiples ubicaciones**: Administración centralizada
- **Inventario por sucursal**: Control independiente de stock
- **Empleados por sucursal**: Asignación de personal

### 💰 Sistema de Ventas
- **Procesamiento de ventas**: Carrito de compras funcional
- **Facturación**: Generación de comprobantes
- **Reportes**: Análisis de ventas por período
- **Historial**: Seguimiento de transacciones

### 👥 Gestión de Empleados
- **Registro de personal**: Administración de empleados
- **Asignación de sucursales**: Control de ubicación
- **Permisos**: Niveles de acceso diferenciados

## 🎯 Cumplimiento de Requisitos

Este proyecto está diseñado para cumplir con todos los puntos solicitados:

✅ **Arquitectura Limpia**: Separación clara de capas (Data, Domain, Presentation)  
✅ **Gestión de Estado**: Implementación con Flutter Bloc  
✅ **Base de Datos**: Integración con Firebase Firestore  
✅ **Autenticación**: Sistema seguro con Firebase Auth  
✅ **CRUD Completo**: Operaciones para todas las entidades  
✅ **Interfaz Moderna**: Material Design 3 y UX optimizada  
✅ **Navegación**: Sistema de rutas bien estructurado  
✅ **Modelos de Datos**: Entidades bien definidas con Equatable  
✅ **Servicios**: Capa de abstracción para acceso a datos  
✅ **Responsive**: Adaptable a diferentes tamaños de pantalla  

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.7.2 o superior
- Dart SDK
- Android Studio / VS Code
- Cuenta de Firebase

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone [url-del-repositorio]
cd proyecto_modulo
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
   - Crear proyecto en [Firebase Console](https://console.firebase.google.com)
   - Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
   - Colocar archivos en las carpetas correspondientes

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 📁 Estructura Detallada

### Capa de Datos (`data/`)
- **Models**: Entidades de dominio con serialización JSON
- **Services**: Implementaciones de repositorios y servicios

### Capa de Presentación (`presentation/`)
- **Modules**: BLoCs y Cubits para gestión de estado
- **Screens**: Interfaces de usuario organizadas por funcionalidad

### Capa Core (`core/`)
- **App Bloc**: Estado global de la aplicación
- **Routes**: Configuración centralizada de navegación

## 🔧 Desarrollo

### Comandos Útiles
```bash
# Análisis de código
flutter analyze

# Ejecutar tests
flutter test

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get
```

### Convenciones de Código
- **Naming**: snake_case para archivos, camelCase para clases
- **Estructura**: Separación clara de responsabilidades
- **Documentación**: Comentarios descriptivos en código complejo

## 📊 Modelos de Datos

- **UserModel**: Gestión de usuarios y roles
- **ProductModel**: Información de productos
- **SaleModel**: Transacciones de ventas
- **SubsidiaryModel**: Datos de sucursales
- **EmployeeModel**: Información de empleados

## 🎨 Interfaz de Usuario

- **Material Design 3**: Componentes modernos y accesibles
- **Navegación Intuitiva**: Flujo de usuario optimizado
- **Responsive Design**: Adaptable a diferentes dispositivos
- **Temas**: Soporte para modo claro y oscuro

## 📈 Próximas Mejoras

- [ ] Notificaciones push
- [ ] Sincronización offline
- [ ] Reportes avanzados
- [ ] Integración con sistemas de pago
- [ ] Dashboard con métricas en tiempo real

## 🤝 Contribución

Este proyecto forma parte del Módulo 8 de la Maestría, implementando las mejores prácticas de desarrollo móvil y arquitectura de software.

## 📄 Licencia

Proyecto académico - Módulo 8 Maestría
