# TpAPDirectaLabo4G3
# FlixFinder

FlixFinder es un prototipo de una aplicación desarrollada en Flutter, diseñada para permitir a los 
amantes del cine y la televisión descubrir información detallada sobre películas, series y actores 
populares de manera rápida y sencilla.

Este proyecto fue desarrollado por Clemente Nicolás, Mattei Stefano y Racciatti Carla como un trabajo 
práctico de aprobación directa de la materia Laboratorio IV (Profesor Sebastián Gañan -  UTN FRBB)

### Pantallas Globales 
- Home Screen 
- Drawer menu para navegar entre pantallas
- Perfil de usuario con datos personales y switch de tema (Dark/Light)
- AppBar personalizado reutilizable
- Archivo unificador `screens/screens.dart`


### 🎭 Sección de Actores

#### Características Principales
- Lista de actores populares con carga incremental. Cargará más resultados a medida que el usuario constinúe haciendo scroll. 
- Búsqueda y filtrado de actores por nombre
  Para buscar se debe escribir el nombre del actor a buscar y luego presionar "enter" en el teclado o el ícono de la lupa en pantalla. 
- Obtención de detalles completos de cada actor:
  - Foto de perfil
  - Nivel de popularidad
  - Biografía detallada con widget personalizado "expandable text". 
    Presionar "leer más" para expandir el texto de la biografía y leer la totalidad. 
    Presionar "ver menos" para contraer el texto nuevamente. 
- Formulario para que el usuario complete reseñas sobre los actores
- Switch para marcar actores como favoritos
(Los datos de reseñas y favoritos se guardan persistentemente en la base de datos del backend)


### 🎬 Sección de Películas

#### Características Principales
- Grid view responsivo de películas
- Barra de búsqueda avanzada
- Filtros por género con Chips
- Pantalla de detalles detallada:
  - Animación Hero para imágenes
  - Información completa de películas
  - Formulario de reseñas
  - Switch de películas favoritas
(Los datos de reseñas y favoritos se guardan persistentemente en la base de datos del backend)

### 📺 Sección de Series
#### Características Principales
- Pantalla principal con serie destacada
- ListView horizontal de recomendaciones
- Búsqueda de series personalizada
- Pantalla de detalles con información detallada


## Tecnologías principales: 
- **Flutter**: Framework principal
- **Dart**: Lenguaje de programación
- **APIs**: Integración con la API que desarrollamos anteriormente 
- **HTTP**: para llamadas de red
- **Git y GitHub**: Control de versiones
- **Vercel, Render y Neon**: Páginas de Hosteo para el Frontend, Backend y Base de Datos respectivamente.

## Arquitectura del Proyecto
Estructura de Carpetas
lib/

├── models/         # Definición de modelos de datos

├── screens/        # Pantallas de la aplicación

├── services/       # Servicios para comunicación con API

├── widgets/        # Widgets reutilizables

└── providers/      # Gestión de estado


## Documentación Técnica
### Arquitectura del Frontend
- **Flutter**: Framework para la interfaz de usuario, con Dart como lenguaje.
- **Integración con API**: Consume la API backend para obtener datos de películas, series y actores (de TMDB vía backend), y gestionar datos locales como favoritos y reseñas.
- **Gestión de Estado**: Usa providers para temas (oscuro/claro) y autenticación.
- **Navegación**: Drawer menu y rutas para pantallas principales.

### Componentes Principales
- **Modelos**: Definen estructuras de datos (Movie, Actor, User, etc.).
- **Servicios**: ApiService para llamadas HTTP, AuthService para login, MovieService para operaciones de películas.
- **Pantallas**: HomeScreen para navegación, detalles para visualización, formularios para reseñas.
- **Widgets**: Reutilizables como FavoriteButton, MovieCard, con soporte para modo oscuro.

### Seguridad en el Frontend
- Envío de API_KEY en headers para todas las solicitudes.
- Manejo de tokens JWT para rutas autenticadas.
- Validación básica de formularios.

## Próximas Mejoras
- Mejoras en la interfaz de usuario
- Funcionalidades de favoritos persistentes
- Persistencia de reseñas ingresadas por los ususarios. 



## Cómo Clonar y Ejecutar el Proyecto
1. Clona el repositorio:
   ```
   git clone https://github.com/NicoClemente/FRONTEND_PPS_CLEMENTE
   ```
2. Accede al directorio:
   ```
   cd FRONTEND_PPS_CLEMENTE
   ```
3. Instala dependencias:
   ```
   flutter pub get
   ```
4. generar archivo .env en la carpeta FRONTEND_PPS_CLEMENTE con el contenido del sample.env (RENDER_URL)

5. Ejecuta la aplicación:
   ```
   flutter run
   ```

## Despliegue
- **Frontend**: Desplegado en Vercel - https://frontend-pps-clemente.vercel.app/

## Desarrollador
- Nicolás Clemente S.


¡Gracias por visitar nuestro proyecto!
