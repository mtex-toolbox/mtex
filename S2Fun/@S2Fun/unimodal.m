function sF = unimodal(varargin)
% defines a unimodal spherical function
%
% Syntax
%
%   sF = S2Fun.unimodal
%   sF = S2Fun.unimodal('halfwidth',10*degree)
%
%   v = vector3d(1,1,1)
%   psi = S2DeLaValleePoussinKernel('halfwidth',20*degree)
%   sF = S2Fun.unimodal(v,psi)
%
% Input
%  v - symmetry axis @vector3d 
%  psi - @S2Kernel
%
% Output
%  sF - @S2FunHarmonic
%


% extract kernel
psi = S2DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',25*degree));
psi = getClass(varargin,'S2Kernel',psi);

% the radially symmetric function about the north pole
sF = S2FunHarmonic(psi);

% rotate the north pole onto the symmetry axis
v = getClass(varargin,'vector3d',vector3d.Z);
if angle(v,vector3d.Z) > 0
  sF = rotation.map(vector3d.Z,v) * sF;
end

end
