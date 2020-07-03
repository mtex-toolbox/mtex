function v = times(v1,v2)
% .* - componenwtise multiplication
%
% Syntax
%   v = v1 .* v2
%   v = times(v1,v2) 
% 
% Input
%  v1, v2 - @vector3d
%
% Output
%  v - @vector3d
%

if isnumeric(v1) || islogical(v1)
  v2.x = v1 .* v2.x;
  v2.y = v1 .* v2.y;
  v2.z = v1 .* v2.z;
  v2.isNormalized = false;
  v = v2;
  return
elseif isnumeric(v2) || islogical(v2) 
  v1.x = v1.x .* v2;
  v1.y = v1.y .* v2;
  v1.z = v1.z .* v2;
  v1.isNormalized = false;
  v = v1;
  return
else
  try % omit another if
    v1.x = v1.x .* v2.x;
    v1.y = v1.y .* v2.y;
    v1.z = v1.z .* v2.z;
    v1.isNormalized = false;
    v = v1;
  catch
    error(['Undefined function or method ''times'' for input arguments of type ' class(v1) ' and ' class(v2) '.']);
  end
end