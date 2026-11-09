# Catálogo Oficial de Jefes — VAULT POP!

Este documento detalla la clasificación completa de las imágenes generadas por IA ubicadas en `boses/`, asignando un **Jefe Principal** a cada una de las 10 zonas del juego, y distribuyendo las restantes como **Guardianes Élite / Secundarios** en las zonas intermedias y avanzadas.

---

## 1. Distribución de Jefes Principales (1 por cada Zona)

| Zona | Bioma | Nombre del Archivo | Silueta y Rasgos Visuales | Rol |
| :---: | :--- | :--- | :--- | :---: |
| **Zona 1** | Pradera Verde | `1. Bosque Encantado - Guardian del Bosque (árbol gigante).jpg` | Árbol roble colosal, corteza musgosa, ojos de savia dorada brillante, raíces firmes. | **Jefe Principal** |
| **Zona 2** | Desierto de Piedra | `Desierto Infinito - Escorpion de Arena (escorpion con aguijon).jpg` | Escorpión titánico de quitina ocre, pinzas de piedra arenisca y aguijón neón venenoso. | **Jefe Principal** |
| **Zona 3** | Zona de Hielo | `Tundra Helada - Bruja de Hielo (reina de hielo con cetro).jpg` | Reina glacial esbelta, corona de carámbanos, túnica cian translúcida y cetro helado. | **Jefe Principal** |
| **Zona 4** | Reino de Caramelo | `Caverna de Cristal - Espectro de Cristal (wraith de cristal flotante).jpg` | Espectro prismático de azúcar glass, cristales flotantes rosa y magenta neón. | **Jefe Principal** |
| **Zona 5** | Pantano Rocoso | `Pantano Venenoso - Serpiente Toxica (serpiente enrollada).jpg` | Serpiente monstruosa de ciénaga, escamas verde ácido, ojos amarillos y niebla tóxica. | **Jefe Principal** |
| **Zona 6** | Atlántida / Abismo | `Abismo Acuatico - Leviatan Marino (serpiente marina gigante).jpg` | Leviatán serpentino de aguas profundas, aletas dorsales turquesa y cuernos abisales. | **Jefe Principal** |
| **Zona 7** | Núcleo Volcánico | `Volcan Ardiente - Dragon de Fuego (dragon con alas y cola).jpg` | Dragón titánico de magma, escamas de basalto incandescente y cuernos ígneos. | **Jefe Principal** |
| **Zona 8** | Jardín de Flores | `Arboleda Sagrada - Druida de Naturaleza (druida con cuernos y cetro).jpg` | Druida gigante con astas florecidas, capa de enredaderas y báculo de esporas de luz. | **Jefe Principal** |
| **Zona 9** | Galaxia Prisma | `Ruptura del Vacio - Caminante del Vacio (entidad oscura con tentaculos).jpg` | Ser etéreo cósmico de obsidiana, tentáculos estelares violeta y orbes de gravedad. | **Jefe Principal** |
| **Zona 10** | Planeta Alienígena | `Trono Final - Dios Antiguo (dios final con corona dorada, alas y orbes).jpg` | Deidad alienígena colosal, corona de plasma cósmico, alas de energía y orbes flotantes. | **Jefe Principal** |

---

## 2. Distribución de Guardianes Élite / Secundarios (Zonas 4 a 10)

| Zona | Bioma | Nombre del Archivo | Silueta y Rasgos Visuales | Rol |
| :---: | :--- | :--- | :--- | :---: |
| **Zona 4** | Reino de Caramelo | `Meseta de Tormentas - Titan del Trueno (titan con martillo de rayo).jpg` | Titán de caramelo crujiente electrificado con martillo de piruleta chispeante. | **Guardián Élite** |
| **Zona 5** | Pantano Rocoso | `Ciudadela de Hueso - Nigromante Oscuro (nigromante con calavera y huesos).jpg` | Nigromante de fango y huesos cenagosos, cetro con cráneo fosforescente. | **Guardián Élite** |
| **Zona 6** | Atlántida / Abismo | `Templo Celestial - Silfide del Viento (sylph con alas y halo).jpg` | Náyade / Sirena de las mareas con halo de agua bendita y aletas translúcidas. | **Guardián Élite** |
| **Zona 7** | Núcleo Volcánico | `Camara de Lava - Behemoth de Lava (behemoth de basalto con lava).jpg` | Cuadrúpedo titánico con placas de basalto negro y grietas de lava viva. | **Guardián Élite** |
| **Zona 7** | Núcleo Volcánico | `Grieta Infernal - Demonio del Caos (demonio con alas, cuernos y fuego).jpg` | Demonio infernal con alas de ceniza, cuernos de fuego y garras incandescentes. | **Guardián Élite** |
| **Zona 8** | Jardín de Flores | `Cueva de Piedra - Golem de Roca (golem de roca).jpg` | Coloso de granito cubierto de musgo espeso, raíces y flores gigantes protectoras. | **Guardián Élite** |
| **Zona 9** | Galaxia Prisma | `Arena Celestial - Paladin de Luz (paladin con espada y escudo sagrado).jpg` | Paladín astral con armadura de fotones estelares, espada láser y escudo de prisma. | **Guardián Élite** |
| **Zona 9** | Galaxia Prisma | `Forja Infernal - Coloso de Metal (robot industrial con furnaces).jpg` | Mecha cibernético / robot interestelar con núcleo reactor de fusión nuclear. | **Guardián Élite** |
| **Zona 10** | Planeta Alienígena | `Mazmorra Oscura - Asesino de Sombras (asesino con dagras y aura).jpg` | Cazador xenomorfo alienígena con cuchillas de plasma púrpura y velocidad extrema. | **Guardián Élite** |
| **Zona 10** | Planeta Alienígena | `Cementerio Antiguo - Rey No-Muerto (esqueleto con corona y espada).jpg` | Comandante supremo biomecánico alienígena con coraza cyber-esquelética. | **Guardián Élite** |

---

## 3. Especificaciones de Modelado 3D en Roblox Studio
- **Escala:** Entre 2.5x y 3.5x la altura de un avatar estándar (entre 13 y 18 studs de altura).
- **Físicas y Colisiones:** `HumanoidRootPart` centrado, `CanCollide = true` solo en la hitbox principal; extremidades, cuernos y accesorios con `CanCollide = false` para garantizar libre locomoción.
- **Anclaje al Suelo:** Pies corregidos con el plano de cada bioma ($Y \approx 61.2$) para evitar cuerpos flotantes o enterrados.
- **Comportamiento IA:** Patrullaje autónomo entre 4 waypoints circulares; detección de robo de huevo para activar persecución inmediata (`ChaseMode`) a 1.25x de velocidad, deteniéndose en la frontera del bioma o SafeZone.
