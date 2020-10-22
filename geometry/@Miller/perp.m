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

switch m.dispStyle
  
  case 'hkl'
    
    dispStyle = 'uvw';
  
  case 'hkil'
    
    dispStyle = 'UVTW';
  
  case 'uvw'
    
    dispStyle = 'hkl';
      
  case 'UVTW'
    
    dispStyle = 'hkil';
    
end

m = Miller(perp@vector3d(m),m.CS,dispStyle);

end
