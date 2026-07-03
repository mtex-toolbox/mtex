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
