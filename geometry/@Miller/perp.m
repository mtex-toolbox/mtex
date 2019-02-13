function m = perp(m)
% best normal to a list of directions
%
% Syntax
%   n = perp(d)
%
% Input
%  d - list of @Miller
%
% Output
%  n - @Miller

m = Miller(perp@vector3d(m),m.CS);

switch m.dispStyle
  
  case {'uvw','UVTW'}, m.dispStyle = 'hkl';  
  case 'hkl'
    if any(strcmp(m.CS.lattice,{'trigonal','hexagonal'}))
      m.dispStyle = 'UVTW';
    else
      m.dispStyle = 'uvw';
    end  
end
