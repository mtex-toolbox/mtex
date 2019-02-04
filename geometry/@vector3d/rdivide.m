function v = rdivide(v1,d)
% scalar division v ./ s

if isnumeric(d)
  v = v1;
  v.x = v1.x ./ d;
  v.y = v1.y ./ d;
  v.z = v1.z ./ d;
elseif isnumeric(v1)
  v = d;
  v.x = v1 ./ d.x;
  v.y = v1 ./ d.y;
  v.z = v1 ./ d.z;
else
  try % omit another if
    v = v1;
    v.x = v1.x ./ d.x;
    v.y = v1.y ./ d.y;
    v.z = v1.z ./ d.z;
  catch
    error(['Undefined function or method ''rdivide'' for input arguments of type ' class(v1) ' and ' class(v2) '.']);
  end
end

v.isNormalized = false;