function rot = byHomochoric(v,varargin)
% define rotations by homochoric coordinates
%
% Description
% The inverse of <quaternion.homochoric.html |homochoric|>. A homochoric
% vector points along the rotational axis and has length
%
% $$ \rho = \left(\frac{3}{4}\left(\omega - \sin\omega\right)\right)^{1/3} $$
%
% for the rotational angle $\omega$, so the rotation group is mapped onto a
% ball of radius $(3\pi/4)^{1/3}$. Recovering $\omega$ from $\rho$ has no
% closed form and is done by a Newton iteration started at the small angle
% limit $\omega \approx 2\rho$, which is exact up to $O(\rho^5)$.
%
% Syntax
%   rot = rotation.byHomochoric(v)
%   rot = rotation.byHomochoric([x y z])
%
% Input
%  v - homochoric @vector3d
%
% Output
%  rot - @rotation
%
% See also
% quaternion/homochoric quaternion/cubochoric rotation/byRodrigues

if ~isa(v,'vector3d'), v = vector3d.byXYZ(v); end

rho = norm(v);

% small angle limit, exact up to O(rho^5)
omega = 2 * rho;

% Newton iteration on 3/4 (omega - sin(omega)) - rho^3 = 0
for k = 1:20 %#ok<NASGU>

  f = 0.75 * omegaMinusSin(omega) - rho.^3;

  % 3/4 (1 - cos(omega)), written so that it stays accurate near omega = 0
  df = 1.5 * sin(omega/2).^2;

  % df vanishes only at omega = 0, where the starting value is already exact
  step = f ./ df;
  step(~isfinite(step)) = 0;

  omega = min(max(omega - step,0),pi);

  if all(abs(step(:)) < 1e-15), break; end
end

% the rotational axis is undefined for the identity - any axis will do
isId = rho == 0;
v(isId) = zvector;

rot = rotation.byAxisAngle(v,omega);

end

% -------------------------------------------------------------------------

function d = omegaMinusSin(omega)
% omega - sin(omega), avoiding cancellation for small omega

d = omega - sin(omega);

% below this the direct difference has lost most of its significant digits,
% while four series terms are accurate to about 1e-15 relative
ind = omega < 0.1;
w = omega(ind);
w2 = w.^2;
d(ind) = w.^3/6 .* (1 - w2/20 .* (1 - w2/42 .* (1 - w2/72)));

end
