function SO3VF = rotate(SO3VF,varargin)
% rotate a SO3 vector field by one rotation
%
% Syntax
%   SO3VF = rotate(SO3VF,rot)
%   SO3VF = rotate(SO3VF,rot,'right')
%
% Input
%  SO3VF - @SO3VectorField
%  rot   - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%
% See also
% SO3VectorFieldHandle/rotate SO3VectorFieldHarmonic/rotate SO3VectorFieldRBF/rotate

% -------------------------------------------------------------------------
% Why rotating the argument alone is not enough
% -------------------------------------------------------------------------
%
% A tangent vector is not a free vector. In the left tangent space
% representation the tangent element in R is the matrix s*R, in the right
% representation it is R*s, where s is the spin tensor built from the
% coordinates v the SO3TangentVector stores. Rotating a vector field
% therefore rotates the frame these coordinates refer to - but only if the
% rotation acts from the same side the tangent space is defined on, since
% only then it interferes with the perturbation exp(t*v) which generates
% the tangent space.
%
% For the gradient of an SO3Fun this reads as follows. A rotation from the
% left (rotation of the specimen, the default) gives f_q(R) = f(q^-1 R) and
%
%   left  tangent space:  grad f_q (R) = q * (grad f)(q^-1 R)
%   right tangent space:  grad f_q (R) =     (grad f)(q^-1 R)
%
% since q^-1 exp(t*v) R = exp(t * q^-1 v) q^-1 R  rotates the perturbation,
% while  q^-1 R exp(t*v)  leaves it untouched. A rotation from the right
% (rotation of the crystal, the option 'right') gives f_q(R) = f(R q^-1) and
% by the same argument
%
%   left  tangent space:  grad f_q (R) =        (grad f)(R q^-1)
%   right tangent space:  grad f_q (R) = q^-1 * (grad f)(R q^-1)
%
% Hence the coordinates of the tangent vectors have to be rotated by q
% (resp. q^-1) whenever the side of the rotation coincides with the intern
% tangent space representation, and are left alone otherwise.
% -------------------------------------------------------------------------

SO3VF = SO3VectorFieldHandle(SO3VF);

SO3VF = rotate(SO3VF,varargin{:});