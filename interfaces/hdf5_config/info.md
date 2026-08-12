# Writing a config

Every entry below a block with `"multiple": true` - the phase list of `cs` -
must match exactly **one** data set per phase. The number of phases is not
taken from the file, it is implied by the number of matches, so a regex like
`"Symmetry$|LGsymID"` that hits two data sets of the same phase silently
doubles the phase list and shifts the phase ids of the map.

## Where an entry is searched

An entry states its `mode`, which decides what its `value` is matched against:

| mode | searched below | matched against |
| --- | --- | --- |
| `absolute` | - | the full path, literally |
| `search_root` | the enclosing `key` | the full path |
| `search_free` | the group *containing* the data set | the full path |
| `search_set` | the selected data set | the path **relative** to it |

`search_free` is the one to reach for a value stored next to the data set
rather than inside it - EDAX keeps the step size in a `Sample` group beside
`EBSD`, Oxford states it in the `EBSD` header even for its processed version.

`search_set` is the only mode that can tell two data sets apart that live in
the same group, which is what Oxford needs: `/1/EBSD` and
`/1/Data Processing` are two versions of one map and both sit under `/1`.
Because it matches relative paths it also anchors exactly - `"^/Header$"` is
the header of the data set and not the header of every analysis stored inside
it.

The `ebsd` `key` may offer several alternatives, and their order is the
preference order: with `"/Data Processing$|/EBSD$"` a file holding both lists
the processed version first and imports it unless the other one is asked for.
An `additions` block may carry an `exclude` list of regular expressions over
the property names, for per pixel data sets that are read some other way and
would otherwise come back as duplicated properties.

# Bruker

Euler vs. Map Coordinate system:
/EBSD/Header/Coordinate Systems/ESPRIT Coordinates -> image
/EBSD/Header/Coordinate Systems/ID                 -> Id
id = 5 --> rotation Y, 180


Crystal vs. Cartesian Coordinate systeme:
c||z, x||a*
b in yz ebene -> x⟂b -> 

/EBSD/Header/Phases/1/Setting  intern numeration of space group




how2plot:
| ->x
V
y

# EDAX

Euler vs. Map Coordinate system:
/EBSD/Header/Coordinate System/ID
setting 1:  225  180  135
setting 2:  135  180  225
setting 3:  270  180   90 
setting 4:  180  180  180
in setting 1,2 is SEM View / how2plot x->south, y->east
in setting 3,4 is SEM View / how2plot x->east, y->south

Crystal vs. Cartesian Coordinate systeme:
/EBSD/Header/Cartesian Alignment -> almost MTEX syntax

usually not MTEX default, i.e., x||a for trigonal and hexagonal

If "Cartesian Alignment" is missing the config falls back to the option
"EDAX", which is the very same convention the .ang / .osc interfaces use:
x||a for triclinic, trigonal and hexagonal lattices, MTEX default otherwise
(see geometry/@crystalSymmetry/private/calcAxis.m). The .edaxh5 and EMSphInx
configs use "EDAX" unconditionally since those files do not state their
alignment.


# Oxford

A map may be stored twice, as recorded under `/<n>/EBSD` and as cleaned up by
the vendor software under `/<n>/Data Processing`. Both are offered as data
sets. They share the very same `Data/Euler` and `Data/Phase` - what the
processing adds is the derived `Analyses` groups, a reduced set of per pixel
properties and a specimen orientation.

The processed version stores no `Data/X`, `Data/Y` and no step size of its
own, hence `position` is built from the step size in the `EBSD` header for
both versions - which is exact, every Oxford map seen so far satisfies
`X Cells * Y Cells == numel(Phase)`.

## Euler vs. Map Coordinate system

The [H5OINA specification](https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md)
names five frames and defines `Data/Euler` as the orientation of the crystal
(CS2) to the **sample surface (CS1)**.

`Header/Specimen Orientation Euler` is **not** the correction MTEX needs. The
spec defines it as the orientation of sample-surface (CS1) to *sample-primary*
(CS0), where CS0 is a frame the user picks - RD/TD/ND for a rolled sheet,
foliation/lineation for a rock. MTEX has no notion of a second specimen frame,
and `ebsd.EulerCorrection` means Euler -> **map**, so this field is
deliberately not read. Reading it used to make an import depend on whether
somebody had opened the file in AZtec Crystal and typed a sample-primary
frame: it is mandatory in the `EBSD` header, where it has been zero in every
file seen so far, and optional under `Data Processing`, where AEVJ1_anon
carries (30, 45, 20) degree. That is why the two data sets of AEVJ1_anon used
to disagree by 66 degree although their `Data/Euler` are byte identical.

The correction that *is* applied comes from `Header/Scanning Rotation Angle`,
spec'd as the *"angle between the specimen tilt axis and the scanning tilt
axis"* - a turn about the surface normal, taken as a rotation about z by the
`map_correction` formatter `scanRotation`. This is the long known AZtec "map
in beam view, orientations in camera view" mismatch, which the `.ctf` and
`.crc` interfaces have to *assume* to be 180 degree (see
`applyEulerCorrectionFixed`) while `h5oina` states it per acquisition. Across
the 18 Oxford files at hand it is pi for 12 and 0 for 6 (`Cu_Al_NSs Cu Ref
AD`, the four `BenWorkshop` Mg / Ti6246 maps), so it is genuinely not
constant. A `NaN` means "unknown" and is treated as no correction.

It is read with `search_free` anchored at `/EBSD/Header/...`, not with
`search_set`: `Data Processing/Header` does not repeat the angle, and the two
versions of a map must not end up in different frames.

Verified against the one map that exists in both formats,
`publications/23_JeanSebastian/Archive/oli_test.ctf` and `oli_test.h5oina`
(`AcqE1/2/3 = 0` and `Specimen Orientation Euler = 0`, i.e. CS0 = CS1, so both
files carry the same Euler numbers). Before this correction the two imports
had identical positions but orientations 180.0000 degree apart at all 29709
indexed pixels; now they agree to 1.1e-4 degree, which is the float32 against
text precision difference that the 2023 script `h5oina_does_not_filter.m` next
to those files already attributed to rounding.

Two things this does **not** settle. The twin test shows `h5oina` and `.ctf`
now agree, not that the shared 180 degree is physically right - that needs a
specimen of known orientation, see `quartz_orientation_calibration
...h5oina`, or a rotation/tilt test. And the sign of the angle is unverified:
every value seen so far is 0 or pi, which are their own inverses.
`Header/Detector Orientation Euler` (CS3 -> microscope) plays no role in this.

## The traditional Oxford formats, ctf and crc/cpr

Not hdf5, but the same vendor and the same question, and the conclusions
differ - so they are recorded here next to the h5oina reasoning rather than
being rediscovered.

`.ctf` states `AcqE1/2/3` and `.cpr` an `[Acquisition Surface]` section with
`Euler1/2/3`, both in degree. These are one and the same quantity: the
`EDXLMDTi64_alpha` map is exported both ways and carries `-90, 0, 0` in each.
It is also the same quantity as h5oina's `Specimen Orientation Euler`, i.e.
the acquisition surface CS1 against the user's own CS0, which is exactly the
field that is *not* read for h5oina. So neither loader applies it - doing so
would reintroduce in `.ctf` and `.crc` the very problem removed from the
Oxford config. Since MTEX 7 the value is reported when it is not zero, so a
user at least learns that the acquisition was not set up the way the assumed
180 degree takes for granted; the note is suppressed for `'wizard'`, for an
explicit `'EulerCorrection'` and under `generatingHelpMode`. It is not rare -
non zero in 4 of the 11 `.ctf` and 3 of the 4 `.cpr` files at hand, and
`niessen/TRWIP_HR_1CC.cpr` puts its `-90` on the *second* angle, so it is not
a constant either.

Two reasons not to simply mirror the h5oina fix here:

* a `.ctf` header states *"Euler angles refer to Sample Coordinate system
  (CS0)!"*. If that is literal the export has already applied the acquisition
  surface orientation and `AcqE` is a record of what was done, so applying it
  again would double count.
* neither format appears to state anything like `Scanning Rotation Angle`.
  The `.ctf` header carries `TiltAngle` and `TiltAxis` but nothing for the
  beam view against camera view turn, which would mean the hardcoded 180
  degree there is unavoidable rather than lazy.

Deciding this needs a `.ctf` with a non zero `AcqE` together with the h5oina
of the same map. `oli_test` has `AcqE = 0` and cannot distinguish the cases;
`EDXLMDTi64_alpha` has `-90` but no h5oina twin.

Crystal vs. Cartesian Coordinate systeme:
??? seems to be default MTEX convention x||a* z||c


# ThermoFisher



Crystal vs. Cartesian Coordinate systeme:
default MTEX convention x||a* z||c
