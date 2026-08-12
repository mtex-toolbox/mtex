function v1 = plus(v1,v2)
% pointwise addition

if isnumeric(v1)
  v2.x = v2.x + v1;
  v2.y = v2.y + v1;
  v2.z = v2.z + v1;
  v1 = v2;
elseif isnumeric(v2)
  v1.x = v1.x + v2;
  v1.y = v1.y + v2;
  v1.z = v1.z + v2;
elseif isa(v2,'vector3d')
  v1.x = v1.x + v2.x;
  v1.y = v1.y + v2.y;
  v1.z = v1.z + v2.z;
else % EBSD, grain2d, SO3VectorField, ... - let the other class do the work
  v1 = plus(v2,v1);
  return
end

v1.isNormalized = false;

% cached theta, rho, resolution, searcher, ... refer to the old coordinates
if ~isempty(fieldnames(v1.opt)), v1.opt = struct; end
