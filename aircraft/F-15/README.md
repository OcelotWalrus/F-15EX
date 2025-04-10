---
CROMHⒶ'S HERE
---

This project aims to enhance the already-existing F-15C and D models originally made by Richard Harrison and other various contributors. **But**, the main aim is to develop the F-15EX model from that already-existing model, only changing the cockpit's model, being extremely different from the F-15C, but also add as much as weapons as the F-16 FlightGear model, develop A/G operations by adding more bombs types, racks and etc. The development of the MPCD (multi-page control display), the TWS radar display (for example use different symbols for unknown objects or missiles etc.), the HUD (adding modes and more useful info and new symbology). The creation of a very detailed PDF manual is also under development.

_Note that the C and D variant are probably bugged because I never test them. Will gotta at some point..._

For now, what's been done is (all these changes only apply to the F-15EX variant if not specified):

- The creation of the EX variant (cockpit model is still old F-15C)
- The enhancement of the C variant cockpit (added simulation of chaff/flare release and low ammo lights, engine flame out oral warning)
- Added more payload options, through custom rack count or new stores (2 x AIMs, and bombs)
- Added F-15EX new secondary wing pylons
- Added F-15EX new two fuselage pylons for nav and target pods
- The addition of new A/A missiles: AIM-9X, and the AIM-120D (all weapons are only for EX variant)
- The addition of new A/G bombs: MK-82, MK-82AIR, MK-83, MK-84, CBU-87, CBU-105, and B61-12 (all weapons are only for EX variant)
- The addition of misc weapons: LAU-68C (only EX variant)
- The addition of more aerodynamic effects such as mach cone or strake and G vortex
- The polishing of already-existing effects
- The addition of neat fictional liveries
- Rebranded the F-15EX tab, by adding the F-15EX Eagle II config panel, where you have everything you need to configure the plane and the flight
- The polishing of various sound effects (gun, flares etc.)
- Enhanced the HUD to have clearer calibrated airspeed shown, as well as ground speed with it, AOA, clearer current altitude, ft/s indicator below altitude as a landing help, the currently selected armament type if ARM ON, and the chaff and flare count if ARM ON, and display the last launched missiles with a diamond to track their path, and also display estimated time for bomb or missile to hit target, relative aspect of the target.
- The addition of custom FlightGear AI scenarios for either strike, target interception or dogfight situations
- Added a dragchute (all variants and don't depend on liveries like the F-16 for example)
- Added `I` keybind to toggle emergency flare/chaff release (10/sec instead of 2/sec)
- You now have to hold Ctrl-Q to release flares/chaffs, instead of pressing once to trigger and once again to stop loop
- Addition of gear, brakes and flaps overspeed damage : when flaps are oversped (about 250 kts), they go to 0 degrees and are locked - when gear is oversped, one of the three gear will be broken - when parking brakes are oversped (about 50 kts) or wheel brakes are oversped (about 150 kts), brakes will not work anymore
- Added ground models (ramps, extinguisher) when aircraft is offline (models coming from FlightGear's F-16 model)
- Now check if ground power unit is present when turning external power switch on (won't work if the GPU isn't present)
- Added a nicer exhaust trail
- Added the LANTIRN Navigation Pod, which that the FLIR displayed on the HUD, and a TFR (Terrain Following Radar), which allows the plane to autopilot at a certain altitude above the ground, customized either in the F-15EX Eagle II config panel or the PACS page related to the nav pod (actually doesn't work well with unsmooth ground transitions)
- Display steerpoints on the HUD using same method as F-16 model
- Added ASE Circles to the HUD and more A/A missile symbology
- Added the ability to fire AIM-9s, unslaved to the radar, and the ability to cage or uncage AIM-9s (with that HUD symbology)
- Upgraded the landing/taxiing light bulb effects
- Added a "FLYUP", "FUEL", "NO RAD" and "LIMIT" warning displays on the HUD (with sounds)
- Added the ability to customize the ripple count in the MPCD
- Added the ability to specifically select a weapon in the HUD (not just type (MRM, SRM or Ground) but actual weapon types (manually choosing from AIM-120, AIM-7))
- Implemented ripple release (from 1 to 4)
- Added CFT pylons (3 each side)
