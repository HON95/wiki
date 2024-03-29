---
title: Licensing
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## Resources

- [Choose a License](https://choosealicense.com/)
- [Wikipedia: Software license](https://en.wikipedia.org/wiki/Software_license)
- [Wikipedia: License compatibility](https://en.wikipedia.org/wiki/License_compatibility)
- [GNU Project: Various Licenses and Comments about Them](https://www.gnu.org/licenses/license-list.en.html)
- [GNU Project: How are the various GNU licenses compatible with each other?](https://www.gnu.org/licenses/gpl-faq.html#AllCompatibility)
- [FOSSA (Open Source Management for Enterprise Teams)](https://fossa.com/) (For managing licenses for dependencies, finding licensing conflicts, generating attibution notices, and more.)

## Definitions

- Free software: The software is free to be used, distributed and modified. "Free" as in "free speech," not as in "free beer". (See the four essential freedoms of free software.)
- Open source software (OSS): The source code is openly shared.
- Free and open source software (FOSS): Both free and open source, since the two differ in philosophy.
- Proprietary software: The software is under copyright licensing. The source code is typically not shared.
- Copyleft license: The work may be freely modified and distributed as long as the derivative works preserve the same rights. Permissive licenses, however, do not put any restrictions on derivative works. In other words, permissive works may be used in proprietary works while copyleft works may not.
- License compatibility: Licenses are said to be compatible if they can both be applied to a work without conflict. In other words, the software must be able to satisfy both/all the licenses.

## License Types

- Public domain:
    - The author(s) waives all rights of the product, allowing others to use/modify/distribute it without even mentioning the author.
    - Examples: Unlicense, Creative Commons CC0, BSD0.
- Permissive license:
    - Allows anyone to use/modify/distribute the software as long as they credit the author.
    - It does not restrict changing or removing the license from derivative works, including proprietary works.
    - Examples: MIT, BSD, Apache.
- Restrictive license:
    - Aka copyleft and protective license.
    - Like permissive licenses, but requires that derivative works are released under the same license.
    - Examples: GNU Public License (GPL), Eclipse Public License (EPL).
- Proprietary license:
    - Non-free, the owner may restrict usage/modification/distribution of the product as they want.
    - The source code is typically copyrighted and not made accessible.
- Non-commercial license:
    - Aka freeware and freemium software.
    - Describes software that's free to use, but may charge for extra features or show ads.
    - Like proprietary software, the source code is typically copyrighted and not made accessible.
- Trade secret:
    - For internal software which is not made public directly.

## Usage

- Using a library in an application generally means "creating a derivative work" of the library.
    - LGPL does not consider dynamic linking as creating a derivative work.
- "Using" a library applies to running code. The source code may be licensed e.g. under a compatible license like MIT and using e.g. a GPL library and then become subject to the GPL restrictions only after the application is built. This means that build options may cause different licenses to apply based on which libraries/components it uses.
- Re-licensing a work requires permission from all code owners. Contributed code is typically owned by whoever contributed that code.
- In some circumstances, multiple programs/libraries may be used by the same system/program without requiring them to be compatible. E.g. multiple applications installed in the same system or multiple modules used at the same time (generally).
- Exceptions can be made to the standard licenses, for instance to modify how the license for your work affects derivative works. The work must still adhere to other imposed licenses, though.
- An attibution notice must be added within your software for all direct and indirect dependencies it's using.

## Compatibility

- GPL and permissive licenses: GPL programs may be libraries using the permissive licenses MIT, BSD (two- and three-clause form), MPL 2.0 and LGPL, but not the other way around.
- GPLv2 and GPLv3:
    - GPLv3 is generally compatible with more licenses than GPLv2.
    - GPLv3 programs may *not* use GPLv2-only libraries.
    - GPLv2-only programs may *not* use GPLv3 libraries.
    - GPLv2-or-later programs may use GPLv2 libraries, resulting in a GPLv2 program.
    - GPLv2-or-later programs may use GPLv3 libraries, resulting in a GPLv3 program.
    - GPLv2-or-later programs may use GPLv2-or-later libraries, resulting in a GPLv2-or-later program.
    - GPLv3 programs may use GPLv2-or-later libraries, resulting in a GPLv3 program.
    - Mixing GPLv2-only and GPLv3 libraries is not possible.
    - GPLv2/v3 may be licensed as "GPLv2/v3 or later" to try to avoid the GPL inter-version incompatibilities with current or upcoming versions.
- Apache 2.0 and GPL: Apache 2.0 libraries may be used by GPLv3 programs but *not* GPLv2 programs. Neither GPLv3 nor GPLv2 libraries may be used in Apache 2.0 programs.

## Recommendations

- Try to avoid licensing libraries as GPL. Using these libraries is a nightmare, even for GPL applications (due to GPLv2 and v3 incompatibilities).

{% include footer.md %}
