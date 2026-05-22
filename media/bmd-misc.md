---
title: "Blackmagic Design: Miscellanea"
breadcrumbs:
- title: Media
---
{% include header.md %}

## VISCA

VISCA is a camera control protocol that runs over the RS-422 serial electrical standard. It may run over e.g. RS-232, but BMD devices generally only support RS-422 using a female DE-9 connector. The BMD device acting as the controller typically only has one VISCA port, so that VISCA-controlled devices must be daisy-chained and therefore typically have both an input and an output port (or a combined port). Up to 7 cameras can be daisy-chained.

### BMD DE-9 to Sony 9-pin Phoenix

On Blackmagic devices it typically uses a DE-9 female connector with the following pinout:

![Blackmagic DE-9 female connector pinout](/media/files/bmd-de9-pinout.png)

On certain Sony PTZ cameras, like the EVI-H100S, it uses a 9-pin phoenix female connector (part number 1840434) with the following pinout:

![Sony 9-pin Phoenix female connector pinout](/media/files/sony-phoenix-pinout.png)

I've not found any appropriate adaptor cables online, so buying a normal DE-9 cable (with all internal cables present) and replacing one of the connectors with the Phoenix connector seems to be the simplest alternative. For some reason I had to swap plus/minus on the ATEM side (in addition to RX/TX).

For longer cable runs, one could instead make a Cat6 adaptor cable from DE-9 to RJ45 (8P8C) and a separate Cat6 adaptor cable from RJ45 to 9-pin Phoenix. I have no idea how long this cable could be and if Cat6 is needed, as I've not seen any ratings or requirements around this perhaps hacky method. As the 9-pin Phoenix connector in this case is both for in and out, one could either use separate cables for in and out or use one Cat6 cable for both in and out and split it into separate in and out at the other end (Cat6 has 4 twisted pairs, RS-422 only uses 2).

PS: The Sony EVI-H100S has a dip switch where RS-422 must be enabled (switch 3 on) and to use baud rate 38400bps (switch 4 on).

{% include footer.md %}

NOTES:

-
