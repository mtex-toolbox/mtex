function v = times(v1,v2)
% overload pointwise product .*

if ~isnumeric(v1) && ~isnumeric(v2)
  error(['For tangent vectors, there is no multiplication method. ' ...
    'It is only possible to scale them.'])
end

v = times@vector3d(v1,v2);

end
