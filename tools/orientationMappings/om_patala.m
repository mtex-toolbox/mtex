function [rgb,options] = om_patala(o,varargin)
% converts misorientations to rgb values
%-------------------------------------------------------------------------%
%Filename:  om_patala.m
%Author:    Oliver Johnson
%Date:      7/12/2013
%
% OM_MISORIENTATION provides colorcoding using the Patala colorcoding
% scheme [1], for colorcoding grainboundaries according to misorientation.
%
% Inputs:
%   o - An array of MTEX orientation objects (or an S2Grid object) defining
%       the misorientations for which the computation of disorientations is
%       desired. In the case that o is an S2Grid object, the grid points
%       define misorientation axes and the misorientation angle must be
%       supplied separately (see omega below).
%   CS - (optional) If o is an S2Grid object, then one must provide, as an
%        additional property/value pair of arguments, the crystal symmetry,
%        for example om_patala(o,'CS',symmetry('432'))
%   omega - (optional) If o is an S2Grid object, then one must provide, as
%           an additional property/value pair of arguments, the
%           misorientation angle. omega must be a scalar, which defines the
%           misorientation angle for all misorientation axes provided in o.
%
% Outputs:
%   rgb - A numel(o)-by-3 array defining the colors assigned to each of the 
%         misorientations in o. rgb(i,:) is a 3 element vector of the form
%         [r_value g_value b_value] indicating the color assigned to the
%         misorientation o(i) according to the Patala coloring scheme.
%
% [1] S. Patala, J. K. Mason, and C. A. Schuh, �Improved representations of
%     misorientation information for grain boundary science and 
%     engineering,� Prog. Mater. Sci., vol. 57, no. 8, pp. 1383�1425, 2012.
%-------------------------------------------------------------------------%


switch class(o)
  case 'orientation'
    % get crystal symmetry
    cs = get(o,'CS');
    
    % get point group name
    cs = pointgroup(cs);
    
    % test for supported point group
    assert(any(strcmpi(cs,{'23','222','422','432','622'})),'Point group %s is not supported for Patala colormapping. \nOnly the following point groups are supported: ''23'',''222'',''422'',''432'',''622''.',cs);
    
    % get disorientations
    m = [get(o,'a'),get(o,'b'),get(o,'c'),get(o,'d')];
    d = disorientation(m,cs);
    
    % get rodriguez vectors
    r = bsxfun(@rdivide,d(:,2:4),d(:,1));
  case 'S2Grid'
    % get crystal symmetry
    cs = get_option(varargin,'CS');
    
    % get point group name
    cs = pointgroup(cs);
    
    % get misorientation angle
    omega = get_option(varargin,'omega');
    
    % get spherical coordinates
    theta = get(o,'theta');
    phi = get(o,'rho'); %MTEX calls the azimuthal angle rho
    
    % get disorientations
    m = [cos(omega/2)*ones(size(theta(:))),...
      sin(omega/2).*sin(theta(:)).*cos(phi(:)),...
      sin(omega/2).*sin(theta(:)).*sin(phi(:)),...
      sin(omega/2).*cos(theta(:))];
    d = disorientation(m,cs);
    
    % get rodriguez vectors
    r = bsxfun(@rdivide,d(:,2:4),d(:,1));
    
end

% get rgb colors
switch cs
  case '23'
    rgb = colormap23(r);
  case '222'
    rgb = colormap222(r);
  case '422'
    rgb = colormap422(r);
  case '432'
    rgb = colormap432(r);
  case '622'
    rgb = colormap622(r);
end

options = []; %TO DO: Are there any options we care about?

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

