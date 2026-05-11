function v = mtimes(v1,v2)
% overload product *

if ~isnumeric(v1) && ~isnumeric(v2)
  error(['For tangent vectors, there is no multiplication method. ' ...
    'It is only possible to scale and sum them.'])
end

v = mtimes@vector3d(v1,v2);

end
