---
title: Image Basics
breadcrumbs:
- title: Media
---
{% include header.md %}

## Color Models

- Color models are generally applied per pixel and per frame if video.

### List of Color Models

- RGB:
    - Contains red (R), green (G), and blue (B) components. Often as RGB, sometimes as BGR.
    - It uses additive primary colors, giving white when all three components are max and black when all three components are min.
    - Used mainly for displays and image formats.
    - Often uses a color depth of 8 bits per component (24 bits total, aka RGB24 or RGB888), although other depths are also used.
    - Often considered a "raw" model since e.g. LED and CRT displays use physical red, green and blue components/signals.
    - If gamma correction needs to be emphasised, it may be written as R'G'B' (with primes).
- RGBA:
    - Like RGB, but includes an alpha/opacity (A) component. Often as RGBA, sometimes as ARGB or ABGR.
    - Often using 8 bits per component (32 bits total, aka RGBA32 or RGBA8888).
    - Alternatively as ARGB, with the alpha component first.
- CMY:
    - Contains cyan (C), magenta (M), and yellow (Y) components.
    - It uses subtractive primary colors, giving black when all three components are max and white when all three components are min.
    - Used e.g. in printers and light fixture color wheels.
- CMYK:
    - Like CMY, but contains a key/black (K) component.
    - Since CMY is in practice not very effective for mixing greyscale and deep black (e.g. in printers), the black component is added.
- HSL & HSV:
    - Contains hue (H), saturation (S) and either lightness (L) or value/brightness (V).
    - Alternative representations to RGB, where the color is represented as a point within a cylinder with hue as the angle, saturation as the radius and lightness/value as the height. Often represented as a 2D slice for a given lightness/value, as a 2D rectangle for a given saturation, or as a 2D rectangle for a given hue.
    - Difference between HSL (w/ lightness L) and HSV (w/ value/brightness V):
        - Both L at 0 and V at 0 gives black.
        - L at 1 gives white.
        - V at 1 gives the equivalent of L at 0.5 (i.e. the most saturated color for a given saturation value).
    - A saturation of 0 gives greyscale only, while a saturation of -1 gives the complement color for the specific hue.
    - The hue is continuous and sometimes represented using degrees.
    - The concept of "saturation" in these models is a bit confusing.
- Y'CbCr (and Y'PbPr):
    - Alternatively written as YCbCr or Y'C<sub>r</sub>C<sub>b</sub>. Often confused with Y'UV.
    - Contains luma/luminance (Y'/Y), blue-difference (Cb) and red-difference (Cr).
    - "Y'" (Y prime) is the luma component, i.e. the gamma compressed luminance "Y".
    - The blue- and red-difference is simply blue/red minus luminance (or luma?).
    - While RGB is more appropriate for low-level color (e.g. within displays), Y'CbCr allows for more flexibility wrt. transmission efficiency, e.g. for reducing color depth while keeping luma depth.
    - Y'CbCr is designed for digital video, using only a single digital link for electrical transmission (e.g. SDI). YPbPr is the analog counterpart of Y'CbCr, using separate analog cabling for electrical transmission (e.g. component video) (unlike composite video which multiplexes the analog signals).
    - Chroma subsampling is commonly used to reduce chroma resolution (see the section about the J:a:b notation). Y'CbCr 4:4:4 uses no chroma subsampling but is less commonly used. Y'CbCr 4:2:2 uses 1/4 the number of "color pixels", without significant perceived quality reduction.
- Y'UV:
    - Alternatively written YUV. Often confused with Y'CbCr and Y'PbPr.
    - Previously used for analog encoding, although now it mainly refers to a the color format.
    - Contains luma/luminance (Y'/Y), blue-luminance (U) and red-luminance (V) (for arbitrary variable names U and V).
    - While not directly compatible with Y'CbCr, the Y-Y, U-Cb and V-Cr pairs are pairwise linearly related.
## Color Spaces

- Used to reproducably represent colors from a color model by mapping color model values to/from absolute color space.
- While devices are often labeled for a certain color space, they're often not actually calibrated for it. E.g. for displays, special calibration devices are typically required (if accurate color representation is actually required).
- Generally includes a transfer function (gamma or non-gamma).

### List of Color Spaces

- sRGB (for RGB):
    - The default standard (s) for RGB-derived color models.
    - Created by HP and Microsoft in 1996 and standardized by the IEC.
    - Uses 8-bit color components (RGB24/RGBA32), giving a somewhat limited gamut.
    - Uses a ~2.2 gamma function (not exactly a power function).
- Adobe RGB (for RGB):
    - Similar to sRGB, but uses a wider gamut appropriate for high-end printing (utilising the full CMYK space).
    - Created by Adobe in 1998.
- Rec. 601 (for Y'CbCr video):
    - For 525-line 60Hz and 625-line 50Hz video, with Y'CbCr 4:2:2 color encoding, standardized by the ITU.
- Rec. 709 (aka HDTV video) (for RGB):
    - For FHD, standardized by the ITU.
    - Very similar to sRGB, being created shortly before it.
- Rec. 2020 (aka UHDTV video) (for RGB):
    - For 8K UHD, standardized by the ITU.
- Rec. 2100 (aka HDR-TV video) (for RGB):
    - Extension of Rec. 2020 with HDR support.
    - Supports 10-bit and 12-bit RGB.
- sYCC (for Y'CbCr):
    - Defined in amendments to the sRGB standard.

## Miscellanea

- Color range:
    - The numerical range actually used for each color component.
    - Typically "partial"/"limited" or "full". While full gives a bigger range and might be better internally, it uses more bandwidth during transmission.
    - If this doesn't match, e.g. the black will look too dark or too bright.
- Color gamut:
    - The cimplete subset of colors that can be represented using a given color space (e.g. sRGB) or a certain input/output device (e.g. an LCD display, being limited by the backlight color spectrum).
- Gamma (aka gamma correction/encoding/decoding or transfer function):
    - A power function for changing the mapping 1:1 from a 0–1 input level to a 0–1 output level.
    - Resources:
        - [[W3C] PNG (Portable Network Graphics) Specification: Gamma Tutorial (Appendix)](https://www.w3.org/TR/PNG-GammaAppendix.html)
    - Serves two purposes:
        - For correcting gamma characteristics of cameras or displays.
        - For "smoothing" the perceived brightness over an integer range to reduce the number of required bits to represent a certain perceived bit depth of an image, since human perception also follows a power function for brightness perception.
    - Basic function: `$V_{out} = AV_{in}^{\gamma}$`, where `$V_{in}$` is mapped to `$V_{out}$` using gamma exponent `$\gamma$` and constant coefficient `$A$`.
    - Gamma correction is typically chained (e.g. one gamma for the camera, one for the file format and one for the display), meaning the gamma exponents may simply be multiplied together for the full chain to get the resulting gamma value.
    - The desired resulting gamma is around 1.0–1.5, with higher gammas for dim viewing environments (gives a darker and "shady" image) and lower gammas for bright viewing environments (gives a brighter and "washed" image).
    - The gamma for file formats are typically encoded either in the format itself (e.g. for PNG) or in Exif metadata (e.g. for JPEG). For cameras and displays, it's often specified and sometimes configurable.
    - Only required for integer representations, floating-point representations already handles the problem (although wastes more bits by being more general).
    - Some typical gamma values:
        - CRT displays: 2.5
        - NTSC cameras: 0.45 (to correct for CRT displays)
        - PAL and SECAM cameras: 0.36 (although this is rather low and cameras are typically set higher)
        - SMPTE-170M cameras (newer standard): ~0.5 (although not actually a power function)
- Chroma subsampling:
    - Using a lower resolution (not depth!) for chroma information than for luma information.
    - Useful since humans are more sensitive to luma variations than chroma variations.
    - Used e.g. with JPEG encoding.
    - It uses notation J:a:b. Long story short, 4:4:4 means full chroma resolution, 4:2:2 means halved horizontal resolution but full vertical resulution, and 4:2:0 means halved horizontal and vertical resolution.
    - E.g. Y'CbCr 4:2:2, using 1/3 less bandwidth than Y'CbCr 4:4:4, with almost no visual difference.

{% include footer.md %}
