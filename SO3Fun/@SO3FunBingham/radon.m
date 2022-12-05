function S2F = radon(SO3F,h,r,varargin)
% radon transform of the SO(3) function
%
% Description
% Implements the formulae given in K. Kunze, H. Schaeben, 
% The Bingham Distribution of Quaternions and 
% Its Spherical Radon Transform in Texture Analysis,
% Mathematical Geology, 36, 2004.
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%
% Input
%  SO3F - @SO3FunBingham
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F - @S2FunHarmonic
%
% See also

if nargin<3, r = []; end

if isempty(h)
%   S2F = S2FunHandle(@(h) radon(SO3F,v,r,varargin{:}));
  S2F = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,v,r,varargin{:}),SO3F.CS);
  return
end
if isempty(r)
%  S2F = S2FunHandle(@(r) radon(SO3F,h,v,varargin{:}));
  S2F = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,h,v,varargin{:}),SO3F.SS);
  return
end


f = zeros(length(h),length(r));

% symmetrise h and r
hSym = symmetrise(h,SO3F.CS,varargin{:});
rSym = symmetrise(r,SO3F.SS);

A = quaternion(SO3F.A);

for ih = 1:size(hSym,1)
  for ir = 1:size(rSym,1)
    
    q1 = hr2quat(hSym(ih,:),rSym(ir,:));
    q2 = q1 .* axis2quat(hSym(ih,:),pi);
    
    A1 = dot_outer(q1,A);
    A2 = dot_outer(q2,A);
    
    a = (A1.^2 +  A2.^2) * SO3F.kappa ./2;
    b = (A1.^2 -  A2.^2) * SO3F.kappa ./2;
    c = (A1 .*  A2) * SO3F.kappa;

    bc = sqrt(b.^2 + c.^2);
    f = f + reshape(exp(a) ./ SO3F.C0 .* besseli(0,bc),size(f)) ./ size(hSym,1) ./ size(rSym,1);
              
  end
end
S2F = f * SO3F.weight  ;

end

