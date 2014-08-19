% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% This file is part of MisorientationMaps.
% 
%     MisorientationMaps is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     MisorientationMaps is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with MisorientationMaps.  If not, see <http://www.gnu.org/licenses/>.

function wmax = maxmisorientation(cs)

% get point group name
cs = pointgroup(cs);

% test for supported point group
assert(any(strcmpi(cs,{'23','222','422','432','622'})),'Point group %s is not supported for Patala colormapping. \nOnly the following point groups are supported: ''23'',''222'',''422'',''432'',''622''.',cs);

switch cs
    case '23'
        wmax = pi/2;
    case '222'
        wmax = 2*pi/3;
    case '422'
        k = tan(pi/8);
        wmax = 2*atan(sqrt(1+2*k^2));
    case '432'
        k = tan(pi/8);
        wmax = 2*atan(sqrt(6*k^2-4*k+1));
    case '622'
        k = tan(pi/12);
        wmax = 2*atan(sqrt(1+2*k^2));
end

end

% get point group of a crystal symmetry
function pg = pointgroup(cs)

% get list of symmetry names
sl = SymList;

% find a match
ind = strcmpi(Laue(cs),{sl.Laue});

% return point group name
pg = sl(ind).Rot;

end

%-------------------------------------------------------------------------%
% The functions below (SymList, and addSym) are private functions for the
% MTEX symmetry class, reproduced here locally.
%-------------------------------------------------------------------------%
function l = SymList

l = struct('Schoen',{},'Inter',{},'Laue',{},'Rot',{},'System',{});

% Schoen, Inter, Laue , Rot ,a, b, Typ, Syms
l = addSym(l,'C1' ,'1'    ,'-1'   ,'1'  ,'triclinic'    );
l = addSym(l,'Ci' ,'-1'   ,'-1'   ,'1'  ,'triclinic'    );
l = addSym(l,'C2' ,'2'    ,'2/m'  ,'2'  ,'monoclinic'   );
l = addSym(l,'Cs' ,'m'    ,'2/m'  ,'2'  ,'monoclinic'   );
l = addSym(l,'C2h','2/m'  ,'2/m'  ,'2'  ,'monoclinic'   );
l = addSym(l,'D2' ,'222'  ,'mmm'  ,'222','orthorhombic' );
l = addSym(l,'D2' ,'22'   ,'mmm'  ,'222','orthorhombic' );
l = addSym(l,'C2v','2mm'  ,'mmm'  ,'222','orthorhombic' );
l = addSym(l,'C2v','mm2'  ,'mmm'  ,'222','orthorhombic' );
l = addSym(l,'C2v','mmm'  ,'mmm'  ,'222','orthorhombic' );
l = addSym(l,'D2h','2/m2/m2/m','mmm','222','orthorhombic');
l = addSym(l,'C4' ,'4'    ,'4/m'  ,'4'  ,'tetragonal'   );
l = addSym(l,'S4' ,'-4'   ,'4/m'  ,'4'  ,'tetragonal'   );
l = addSym(l,'C4h','4/m'  ,'4/m'  ,'4'  ,'tetragonal'   );
l = addSym(l,'D4' ,'422'  ,'4/mmm','422','tetragonal'   );
l = addSym(l,'D4' ,'42'   ,'4/mmm','422','tetragonal'   );
l = addSym(l,'C4v','4mm'  ,'4/mmm','422','tetragonal'   );
l = addSym(l,'D2d','-42m' ,'4/mmm','422','tetragonal'   );
l = addSym(l,'D4h','4/mmm','4/mmm','422','tetragonal'   );
l = addSym(l,'D4h','4/m2/m2/m','4/mmm','422','tetragonal');
l = addSym(l,'C3' ,'3'    ,'-3'   ,'3'  ,'trigonal'     );
l = addSym(l,'C3i','-3'   ,'-3'   ,'3'  ,'trigonal'     );
l = addSym(l,'D3' ,'32'   ,'-3m'  ,'32' ,'trigonal'     );
l = addSym(l,'C3v','3m'   ,'-3m'  ,'32' ,'trigonal'     );
l = addSym(l,'D3d','-3m'  ,'-3m'  ,'32' ,'trigonal'     );
l = addSym(l,'D3d','-32/m','-3m'  ,'32' ,'trigonal'     );
l = addSym(l,'C6' ,'6'    ,'6/m'  ,'6'  ,'hexagonal'    );
l = addSym(l,'C3h','-6'   ,'6/m'  ,'6'  ,'hexagonal'    );
l = addSym(l,'C6h','6/m'  ,'6/m'  ,'6'  ,'hexagonal'    );
l = addSym(l,'D6' ,'622'  ,'6/mmm','622','hexagonal'    );
l = addSym(l,'D6' ,'62'   ,'6/mmm','622','hexagonal'    );
l = addSym(l,'C6v','6mm'  ,'6/mmm','622','hexagonal'    );
l = addSym(l,'D3h','-62m' ,'6/mmm','622','hexagonal'    );
l = addSym(l,'D3h','-6m2' ,'6/mmm','622','hexagonal'    );
l = addSym(l,'D6h','6/m2/m2/m','6/mmm','622','hexagonal');
l = addSym(l,'D6h','6/mmm','6/mmm','622','hexagonal'    );
l = addSym(l,'T'  ,'23'    ,'m-3' ,'23' ,'cubic'        );
l = addSym(l,'Th' ,'m3'    ,'m-3' ,'23' ,'cubic'        );
l = addSym(l,'Th' ,'m-3'   ,'m-3' ,'23' ,'cubic'        );
l = addSym(l,'Th' ,'2/m-3' ,'m-3' ,'23' ,'cubic'        );
l = addSym(l,'O'  ,'432'   ,'m-3m','432','cubic'        );
l = addSym(l,'O'  ,'43'    ,'m-3m','432','cubic'        );
l = addSym(l,'Td' ,'-43m'  ,'m-3m','432','cubic'        );
l = addSym(l,'Oh' ,'m3m'   ,'m-3m','432','cubic'        );
l = addSym(l,'Oh' ,'m-3m'  ,'m-3m','432','cubic'        );
l = addSym(l,'Oh' ,'4/m-32/m','m-3m','432','cubic'      );

end

function nl = addSym(l,Schoen,Inter,Laue,Rot,Syst)

s = struct('Schoen',Schoen,'Inter',Inter,'Laue',Laue,'Rot',Rot,'System',Syst);
nl = [l,s];

end