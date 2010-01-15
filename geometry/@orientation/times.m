function r = times(a,b)
% implements quaternion .* orientation and quaternion .* Miller 
%% Input
%  q1 - @quaternion
%  q2 - @quaternion | @vector3d
%
%% Output
%  @quaternion | @vector3d

% orientation times Miller and quaternion times orientation

if isa(a,'orientation') && isa(b,'Miller')
    
  b = set(b,'CS',a.cs);
  r = a.i .* (a.quaternion .* vector3d(b));
  
elseif isa(a,'quaternion') && isa(b,'orientation')
    
  r = b;
  r.quaternion = a .* b.quaternion;
    
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end

