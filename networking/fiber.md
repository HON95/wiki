---
title: Fibers & Fiber Optics
breadcrumbs:
- title: Network
---
{% include header.md %}

## Resources

- [Gigabit Ethernet](https://en.wikipedia.org/wiki/Gigabit_Ethernet)
- [10 Gigabit Ethernet](https://en.wikipedia.org/wiki/10_Gigabit_Ethernet)
- [25 Gigabit Ethernet](https://en.wikipedia.org/wiki/25_Gigabit_Ethernet)
- [40 Gigabit Ethernet](https://en.wikipedia.org/wiki/40_Gigabit_Ethernet)
- [100 Gigabit Ethernet](https://en.wikipedia.org/wiki/100_Gigabit_Ethernet)
- [Terabit Ethernet](https://en.wikipedia.org/wiki/Terabit_Ethernet)

## Cables

- Single-fiber structure:
    1. Core: A high-density medium (generally glass) that the light signal travels through.
    1. Cladding: One or multiple layers of a lower-density medium, such that the lower refractive index causes most light to be confined within the core.
    1. **TODO**
- Multi-fiber structure:
    - **TODO** G's of 12, inner colors
- Single-mode uses a much smaller core diameter (9μm) and thereby allows only a single light mode, whereas multi-mode uses a larger core diameter (50μm or 62.5μm) and uses multiple modes (ensemble of paths for same frequency).
- This means that single-mode has less attenuation over distance, but also that it's (historically) harder to couple fibers and uses more expensive equipment.
- Earlier MMF versions (OM1–2) used LED light sources (aka overfilled launch), while SMF and later MMF versions use lasers (aka effect laser launch) (e.g. VCSEL, FP, DML, EML lasers).
- SMF uses OS1–2 fiber while MMF uses OM1–5 fiber.
- Polarization-maintaining fiber (PMF) is a special type used for maintaining polarization of light.
- Cable colors:
    - See table below.
    - Single-mode PMF cable is blue.

### Types

Approximate distances for commonly used transceivers/technologies. Actual distance varies a lot based on sources and vendors ...

| Type | Diameter (core/cladding) | Distance (1Gb/s) | Distance (10Gb/s) | Distance (25Gb/s) | Distance (40–100Gb/s) | Distance (400Gb/s) | Cable color (typical) |
| -   | -          | - | - | - | - | - | - |
| OS1 | 9/125μm    | 5km (1000BASE‑LX) | - | - | - | - | <span style="background-color: yellow; color: #000;">Yellow</span> |
| OS2 | 9/125μm    | 5km (1000BASE‑LX) | 10km (10GBASE-LR) | 10km (25GBASE-LR) <br/> 40km (25GBASE-ER) | 10km (100GBASE-LR4) <br/> 40km (100GBASE-ER4) <br/> 80km (100GBASE-ZR) | 500m (400GBASE-DR4) <br/> 2km (400GBASE-FR4) | <span style="background-color: yellow; color: #000;">Yellow</span> |
| OM1 | 62.5/125μm | 275m (1000BASE‑SX) | 33m (10GBASE-SR) | - | - | - | <span style="background-color: orange; color: #000;">Orange</span>/<span style="background-color: gray; color: #000;">slate</span> |
| OM2 | 50/125μm   | 550m (1000BASE‑SX) | 82m (10GBASE‑SR) | - | - | - | <span style="background-color: orange; color: #000;">Orange</span> |
| OM3 | 50/125μm   | - | 300m (10GBASE‑SR) | 70m (25GBASE-SR) | 70 (100GBASE-SR4) | 70m (400GBASE-SR8) | <span style="background-color: #7DF9FF; color: #000;">Aqua</span> |
| OM4 | 50/125μm   | - | 400m (10GBASE‑SR) | 100m (25GBASE-SR) | 200 (100GBASE-SR4) | 100m (400GBASE-SR8) | <span style="background-color: #7DF9FF; color: #000;">Aqua</span>/<span style="background-color: #FF69B4; color: #000;">violet</span> |
| OM5 | 50/125μm   | ? | ? | ? | ? | 100m (400GBASE-SR8) | <span style="background-color: #8AE87A; color: #000;">Lime green</span> |

### Trunks

## Connectors

- Polish styles:
    - Polish styles refer to how the ferrule is polished (the part the fiber is threaded into inside the connector). They attempt to reduce reflection back into the fiber, which increases attenuation at connection points.
    - Physical contact (PC) has a slight curvature to reduce the air gap between the cores and was commonly used for OM1–2.
    - Ultra physical contact (UPC) has better polish and larger curvature than PC and is most commonly used now.
    - Angled physical contact (APC) uses an angled polish to reduce attenuation even further. It's commonly used for long-distance fiber where the extra reduction in attenuation matters.

### Types

**TODO**

### Colors

| Cable type | Polish style | Color |
| - | - | - |
| MMF | UPC | <span style="background-color: #F5F5DC; color: #000;">Beige</span> |
| SMF | UPC | <span style="background-color: #3792cb; color: #000;">Blue</span> |
| SMF | APC | <span style="background-color: #3bb143; color: #000;">Green</span> |

## Wavelengths

## Transceivers

**TODO** SFP types

**TODO** BiDi

**TODO** SR/LR/LRM/SX/LX/MPO

{% include footer.md %}
