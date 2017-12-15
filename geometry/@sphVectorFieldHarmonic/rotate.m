function sVF = rotate(sVF, rot)
% rotate a function by a rotation
%
% Syntax
%  sVF = sVF.rotate(rot)
%
% Input
%  sVF - @sphFunHarmonic
%  rot - @rotation
%

sVF = sphVectorFieldHarmonic( ...
  sVF.sF_theta.rotate(rot), ...
  sVF.sF_rho.rotate(rot), ...
  sVF.sF_n.rotate(rot));

end
