function sF = unimodal(varargin)
% defines a unimodal spherical function
%
% Syntax
%
%   sF = S2Fun.unimodal
%   sF = S2Fun.unimodal('halfwidth',10*degree)
%
%   v = vector3d(1,1,1)
%   psi = S2DeLaValleePoussin('halfwidth',20*degree)
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
psi = S2DeLaValleePoussin('halfwidth',get_option(varargin,'halfwidth',25*degree));
psi = getClass(varargin,'S2Kernel',psi);

% define a radially symmetric function
bw = psi.bandwidth;

% 1 3 5  7  9 11 13
% 1 3 7 13 21 31 43 

% the indice of diagonal
l = 0:bw; l = 1+l.^2+l;

f_hat = zeros((2*bw+1)^2,1);
f_hat(l) = psi.A ./ sqrt(2*l+1);

sF = S2FunHarmonic(f_hat);

v = getClass(varargin,'vector3d',vector3d.Z);

if angle(v,vector3d.Z) > 0 
  rot = rotation.map(v,vector3d.Z);
  sF = rot * sF;
end

end
