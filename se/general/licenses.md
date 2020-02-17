---
title: Licenses
breadcrumbs:
- title: Software Engineering
- title: General
---
{% include header.md %}

## Resources

- [Various Licenses and Comments about Them (GNU Project)](https://www.gnu.org/licenses/license-list.en.html)
- [How are the various GNU licenses compatible with each other? (GNU Project)](https://www.gnu.org/licenses/gpl-faq.html#AllCompatibility)
- [FOSSA - Open Source Management for Enterprise Teams](https://fossa.com/)
    - For managing licenses for dependencies, finding licensing conflicts, generating attibution notices, and more.

## Definitions

- Free software: The software is free to be used, distributed and modified. "Free" as in "free speech," not as in "free beer".
  (See the four essential freedoms of free software.)
- Open source software (OSS): The source code is openly shared.
- Free and open source software (FOSS): Both free and open source, since the two differ in philosophy.
- Proprietary software: The software is under copyright licensing. The source code is typically not shared.
- Copyleft license: The work may be freely modified and distributed as long as the derivative works preserve the same rights.
  Permissive licenses, however, do not put any restrictions on derivative works.
  In other words, permissive works may be used in proprietary works while copyleft works may not.
- License compatibility: Licenses are said to be compatible if they can both be applied to a work without conflict.
  In other words, it must be possible to satisfy both/all the licenses.

## Notes

- Using a library in an application generally means creating a derivative work of the library.
    - LGPL does not consider dynamic linking as creating a derivative work.
- "Using" a library applies to running code.
  The source code may be licensed e.g. under a compatible license like MIT and using e.g. a GPL library
  and then become subject to the GPL restrictions only after the application is built.
  This means that build options may cause different licenses to apply based on which libraries/components it uses.
- Re-licensing a work requires permission from all code owners.
  Contributed code is typically owned by whoever contributed that code.
- In some circumstances, multiple programs/libraries may be used by the same system/program without requiring them to be compatible.
  E.g. multiple applications installed in the same system or multiple modules used at the same time (generally).
- MIT projects can not use any GPL libraries.
- GPLv2 and GPLv3 compatibility:
    - GPLv3 programs may *not* use GPLv2-only libraries.
    - GPLv2-only programs may *not* use GPLv3 libraries.
    - GPLv2-or-later programs may use GPLv2 libraries, resulting in a GPLv2 program.
    - GPLv2-or-later programs may use GPLv3 libraries, resulting in a GPLv3 program.
    - GPLv2-or-later programs may use GPLv2-or-later libraries, resulting in a GPLv2-or-later program.
    - GPLv3 programs may use GPLv2-or-later libraries, resulting in a GPLv3 program.
    - Mixing GPLv2-only and GPLv3 libraries is not possible.
- GPLv3 is compatible with more licenses than GPLv2.
- Exceptions can be made to the standard licenses, for instance to modify how the license for your work affects derivative works.
  The work must still adhere to other imposed licenses, though.
- An attibution notice must be added within your software for all direct and indirect dependencies it's using.

{% include footer.md %}
