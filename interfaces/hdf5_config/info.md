# Writing a config

Every entry below a block with `"multiple": true` - the phase list of `cs` -
must match exactly **one** data set per phase. The number of phases is not
taken from the file, it is implied by the number of matches, so a regex like
`"Symmetry$|LGsymID"` that hits two data sets of the same phase silently
doubles the phase list and shifts the phase ids of the map.

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

Euler vs. Map Coordinate system:
/EBSD/Header/Specimen Orientation Euler
/EBSD/Header/Detector Orientation Euler
/EBSD/Header/Scanning Rotation Angle

Crystal vs. Cartesian Coordinate systeme:
??? seems to be default MTEX convention x||a* z||c


# ThermoFisher



Crystal vs. Cartesian Coordinate systeme:
default MTEX convention x||a* z||c
