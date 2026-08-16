function SO3VF = rotate(SO3VF,q,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorFieldHandle
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%
% See also
% SO3VectorField/rotate SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  SO3VF.hiddenCS = dropSymmetry(SO3VF.hiddenCS,q,'crystal','SO3VectorField');
else
  SO3VF.hiddenSS = dropSymmetry(SO3VF.hiddenSS,q,'specimen','SO3VectorField');
end

% Rotating the argument is not enough - the coordinates of the tangent
% vectors refer to the frame the tangent space is attached to, and that frame
% is rotated as well whenever the rotation acts from the same side as the
% intern tangent space representation. See SO3VectorField/rotate for the
% derivation. qC is the rotation the coordinates have to undergo, it is empty
% if they stay untouched.
%
% Note that we use .* and not * - the latter is the outer product of the
% rotations and hence would change the shape of the list of rotations the
% field is evaluated in.
fun = SO3VF.fun;
if check_option(varargin,'right')
  arg = @(r) r .* inv(q);
  qC = inv(q);
  if SO3VF.internTangentSpace.isLeft, qC = []; end
else
  arg = @(r) inv(q) .* r;
  qC = q;
  if SO3VF.internTangentSpace.isRight, qC = []; end
end

SO3VF.fun = @(r) rotateTangentCoordinates(fun(arg(r)),qC);

end

function v = rotateTangentCoordinates(v,q)
% rotate the coordinates of the tangent vectors returned by the function
% handle by q (do nothing if q is empty)
%
% The reference rotations of an SO3TangentVector returned by the inner
% function handle belong to the *unrotated* field, i.e. they are the shifted
% rotations. We therefore return plain coordinates and let
% SO3VectorFieldHandle/eval attach the rotations the rotated field is
% actually evaluated in.

if isa(v,'SO3TangentVector'), v = vector3d(v); end

if ~isa(v,'vector3d')
  % numeric list of coordinates, one row per rotation
  if isempty(q), return; end
  v = vector3d(v.');
end

if ~isempty(q), v = q .* v; end

v = v.xyz;

end
