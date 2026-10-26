# 🌌 CYBERMUSIC

> **Next-Gen Glassmorphic Music Player & Ambient Desktop Experience**  
> *Reproductor de música de escritorio inmersivo para Windows con interfaz de cristal translúcido, fondos dinámicos interactivos y mini reproductor flotante circular con auroras reactivas.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20x64-0078D6.svg?logo=windows)](https://github.com/ROQUE112-star/CYBERMUSIC)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.13.5-02569B.svg?logo=flutter)](https://flutter.dev)
[![Release](https://img.shields.io/badge/Release-v1.0.0%20Stable-00E5FF.svg)](https://github.com/ROQUE112-star/CYBERMUSIC/releases)

---

## ⚖️ Descargo de Responsabilidad y Declaración de Código Abierto (Legal Notice)

> [!IMPORTANT]
> **CYBERMUSIC** es un proyecto independiente de **código abierto (Open Source)** desarrollado con fines estrictamente **educativos, experimentales y de investigación** en diseño de interfaces de usuario avanzadas (UI/UX), aceleración gráfica por GPU con Flutter y personalización de entornos de escritorio.

* **Descargo de marcas registradas:** Este software **NO** está afiliado, asociado, patrocinado, respaldado ni de ninguna manera conectado oficialmente con **Spotify AB**, Spotify Technology S.A. ni ninguna de sus filiales o empresas asociadas. El nombre "Spotify", así como los nombres comerciales y marcas afines, pertenecen a sus respectivos propietarios.
* **Inspiración y modding:** La estética de este proyecto toma inspiración visual de la rica comunidad de personalización estética de escritorio (como el ecosistema de temas de *Spicetify*), aplicándola sobre un motor gráfico propio y código 100% original.
* **Licencia de uso:** El código fuente se distribuye bajo la licencia permisiva **[MIT](LICENSE)**, garantizando libertad de uso, estudio, modificación y distribución sin costo alguno.

---

## ✨ Características Principales

### 1. 🌌 Fondo Dinámico Interactivo (Live Cinematic Background)
* **Tema Espacio Profundo:** Fondo cinematográfico en bucle continuo que muestra un manto estelar infinito.
* **Lluvia de Cometas Activa:** Animación suave y continua de cometas y estrellas fugaces surcando el lienzo para dar una atmósfera viva y relajante.
* **Motor de Importación de Videos:** Sube tus propios videos (`.mp4`, paisajes, anime, bucles abstractos o loops Lo-Fi) desde el panel de configuración con aceleración por hardware.

### 2. 🪟 Efecto de Cristal Translúcido (Glassmorphism de Alta Fidelidad)
* **Paneles de Cristal Esmerilado:** Barra lateral, panel central y barra inferior construidos con efecto *Frosted Glass* y desenfoque dinámico que permite ver el fondo animado a través de ellos.
* **Control Deslizante de Opacidad en Tiempo Real:** Slider interactivo (desde `0%` totalmente transparente hasta `100%` sólido) para adaptar la visibilidad a tu gusto.
* **Sistema de Colores Adaptativos:** Extracción inteligente de la paleta cromática dominante del fondo para armonizar botones, barras de progreso y acentos visuales.

### 3. 💿 Mini Reproductor Flotante Circular ("Bolita" / Floating Bubble)
Al hacer clic en el botón de burbuja flotante o al minimizar la aplicación:
* **Lienzo Circular Puro (Sin marcos rectangulares):** Ventana sin bordes con transparencia *per-pixel* real de Windows (`flutter_acrylic` y DirectComposition).
* **Giro Suave y Pausado del Vinilo:** El disco gira a una cadencia tranquila (ciclo de 28 segundos), evitando movimientos bruscos o mareos visuales.
* **6 Auroras Reactivas Dinámicas:** Efectos de luz periférica que reaccionan a la música y cambian su diseño automáticamente entre canciones (o con doble toque):
  1. *Classic Rays + Cosmic Particles*
  2. *Concentric Ribbon Waves*
  3. *Segmented Dancing Dots*
  4. *Vortex Spikes*
  5. *Dotted Orbital Ring*
  6. *Dual-Tone Corona*
* **Controles Integrados Dentro del Disco:**
  * ⏮️ Canción anterior
  * ⏯️ Reproducir / Pausar
  * ⏭️ Siguiente canción
  * Título de la pista y línea divisoria roja minimalista.
* **Siempre Visible (Always on Top):** Flota por encima de navegadores, juegos u otras ventanas activas.
* **Totalmente Arrastrable:** Puedes moverla suavemente con el ratón por cualquier parte de tu pantalla.
* **Controles Micro:** Botón `-` para restaurar la interfaz completa y `X` para cerrar.

### 4. 🎵 Reproducción, Letras y Personalización
* Soporte para reproducción de música local (`.mp3`, `.wav`, `.flac`) y streaming multimedia.
* **Letras Sincronizadas (Synced Lyrics):** Vista inmersiva con texto a gran tamaño que sigue la música paso a paso.
* **Visualizador de Audio en Tiempo Real:** Espectro de frecuencias reactivo en la barra inferior.
* **Spicetify Studio:** Personalizador de paletas de color y gestor de perfiles de usuario.

---

## 📥 Guía de Instalación y Uso

### Opción A: Versión Portable (Recomendada para usuarios)
No requiere instalar Flutter, Dart ni herramientas de compilación.

1. Descarga el paquete comprimido **`CYBERMUSIC_v1.0.0_Windows_Portable.zip`** desde la sección de **[Releases](https://github.com/Roke-chan/CYBERMUSIC/releases)**.
2. Descomprime el archivo en cualquier carpeta de tu disco local (por ejemplo en `Documentos` o `C:\CYBERMUSIC`).
3. Ejecuta **`CYBERMUSIC.exe`** (o el acceso directo **`CYBERMUSIC.lnk`**).
4. *(Opcional)* Puedes enviar un acceso directo a tu Escritorio haciendo clic derecho en `CYBERMUSIC.exe` ➔ *Enviar a* ➔ *Escritorio*.

---

### Opción B: Compilación desde Código Fuente (Para Desarrolladores)

#### Requisitos Previos:
* **Sistema Operativo:** Windows 10 u 11 (64-bit).
* **Git:** [Descargar Git](https://git-scm.com/).
* **Flutter SDK:** Versión `>= 3.13.5` ([Guía de instalación de Flutter](https://docs.flutter.dev/get-started/install/windows)).
* **Visual Studio 2022:** Con la carga de trabajo *"Desarrollo para el escritorio con C++"* (Desktop development with C++).

#### Pasos de Compilación:

```bash
# 1. Clonar el repositorio
git clone https://github.com/ROQUE112-star/CYBERMUSIC.git
cd CYBERMUSIC

# 2. Descargar paquetes y dependencias
flutter pub get

# 3. Ejecutar en modo desarrollo
flutter run -d windows

# 4. (Opcional) Compilar binario optimizado para producción
flutter build windows --release
```

El ejecutable final se generará en:  
`build\windows\x64\runner\Release\CYBERMUSIC.exe`

---

## 🎮 Guía de Uso Paso a Paso

| Acción | ¿Cómo se realiza? |
| :--- | :--- |
| **Reproducir Música** | Haz clic en cualquier canción de la lista o pulsa el botón central de la barra inferior. |
| **Ajustar Opacidad del Cristal** | En el panel de control lateral / ajustes, mueve el slider deslizante de `0%` a `100%`. |
| **Importar Video de Fondo** | Ve a Configuración ➔ Pulsa **"Importar Video"** y selecciona cualquier archivo `.mp4`. |
| **Modo Burbuja Flotante** | Haz clic en el icono de burbuja en la barra superior o minimiza la aplicación. |
| **Mover la Burbuja** | Haz clic en cualquier parte del cuerpo del vinilo y arrastra con el ratón por la pantalla. |
| **Cambiar Aurora Reactiva** | Doble clic sobre la burbuja flotante o cambia de canción para rotar automáticamente de estilo. |
| **Restaurar Pantalla Completa** | Pulsa el botón `-` en el borde superior de la burbuja. |
| **Cerrar Aplicación** | Pulsa el botón `X` en el borde superior de la burbuja o en la ventana principal. |

---

## 🛠️ Tecnologías y Librerías Utilizadas

* **Framework:** [Flutter](https://flutter.dev) (Desktop Windows C++ Embedder)
* **Renderizado:** Impeller / Skia con aceleración por hardware DirectX/OpenGL
* **Transparencia Nativa:** [`flutter_acrylic`](https://pub.dev/packages/flutter_acrylic) & DirectComposition
* **Gestión de Ventanas:** [`window_manager`](https://pub.dev/packages/window_manager)
* **Motor de Audio:** [`audioplayers`](https://pub.dev/packages/audioplayers)
* **Reproducción de Video:** [`video_player_win`](https://pub.dev/packages/video_player_win)
* **Extracción de Color:** [`palette_generator`](https://pub.dev/packages/palette_generator)

---

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

<p align="center">
  <b>Desarrollado con ❤️ para la comunidad de entusiastas de la música y el diseño de interfaces.</b><br>
  <i>CYBERMUSIC — 2026</i>
</p>
