function sVF = cross(sVF, a)
%
% Syntax
%   sVF = cross(sVF1,sVF2)
%   sVF = cross(sVF1,v)
%
% Input
%  sVF1 - @S2VectorFieldTri
%  sVF2 - @S2VectorField
%  v    - @vector3d
%
% Output
%  sF - @S2VectorFieldTri
%

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
