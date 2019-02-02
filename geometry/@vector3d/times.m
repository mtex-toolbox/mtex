function v = times(v1,v2)
% .* - componenwtise multiplication

if isnumeric(v1) || islogical(v1)
  v = v2;
  v.x = v1 .* v2.x;
  v.y = v1 .* v2.y;
  v.z = v1 .* v2.z;     
elseif isnumeric(v2) || islogical(v2)
  v = v1;
  v.x = v1.x .* v2;
  v.y = v1.y .* v2;
  v.z = v1.z .* v2;
else
  try % omit another if
    v = v1;
    v.x = v1.x .* v2.x;
    v.y = v1.y .* v2.y;
    v.z = v1.z .* v2.z;  
  catch
    error(['Undefined function or method ''times'' for input arguments of type ' class(v1) ' and ' class(v2) '.']);
  end
end

v.isNormalized = false;