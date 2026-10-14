function sVF = cross(sVF, a)
% pointwise cross product of an axis field with a vector field or a vector
%
% Syntax
%
%   sVF = cross(sVF1,sVF2)   % cross product with a field
%   sVF = cross(sVF1,v)      % cross product with a fixed vector
%
% Input
%  sVF1 - @S2AxisFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sVF - @S2AxisFieldTri

% first should be S2VectorFieldTri
if ~isa(sVF,'S2AxisFieldTri')
  sVF = -cross(a, sVF);
  return
end
  
if isa(a,'vector3d')
  sVF.values = cross(sVF.values, a);
elseif isa(a,'S2AxisFieldTri') || isa(a,'S2VectorFieldTri')
  sVF.values = cross(sVF.values, a.values);
else
  sVF.values = cross(sVF.values, a.eval(sVF.vertices));
end

end
