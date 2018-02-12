function [vp,vs1,vs2,pp,ps1,ps2] = velocity(S,varargin)
% computes the elastic wave velocity(km/s) from the elastic stiffness Cijkl
% tensor and density (g/cm3)
%
% Syntax
%   [vp,vs1,vs2,pp,ps1,ps2] = velocity(S)
%   [vp,vs1,vs2,pp,ps1,ps2] = velocity(S,x)
%   [vp,vs1,vs2,pp,ps1,ps2] = velocity(S,x,rho)
%
% Input
%  C   - elasticity @stiffnessTensor Cijkl (UNITS GPa) @tensor
%  x   - list of propagation directions (@vector3d)
%  rho - material density (UNITS g/cm3)
%
% Output
%  vp  - velocity of the p--wave (UNITS km/s)
%  vs1 - velocity of the s1--wave (UNITS km/s)
%  vs2 - velocity of the s2--wave (UNITS km/s)
%  pp  - polarisation of the p--wave (particle movement, vibration direction)
%  ps1 - polarisation of the s1--wave (particle movement, vibration direction)
%  ps2 - polarisation of the s2--wave (particle movement, vibration direction)
%

if nargin >= 2 && isa(varargin{1},'vector3d')
  x = varargin{1};
  generateFun = false;
else
  if check_option(varargin,'harmonic')
    M = 48;
    [x, W] = quadratureS2Grid(2*M);
    generateFun = 1;
  else
    x = equispacedS2Grid('resolution',1.5*degree);
    generateFun = 2;
  end
end

% take density from tensor if not specified differently
if nargin == 3
  rho = varargin{2};
elseif isfield(S.opt,'density')
  rho = S.opt.density;
else
  rho = 1;
  warning(['No density given! For computing wave velocities '...
    'the material density has to be specified. ' ...
    'I''m going to use the density rho=1.']);        
end

% compute ChristoffelTensor
E = ChristoffelTensor(S,x);

% compute eigenvalues
[V,D] = eig3(E.M(1,1,:),E.M(1,2,:),E.M(1,3,:),E.M(2,2,:),E.M(2,3,:),E.M(3,3,:));
  
% compute wavespeeds
D = sqrt(D./rho);
vp = D(3,:); vs1 = D(2,:); vs2 = D(1,:);
  
% the polarisation axes
pp = V(3,:); ps1 = V(2,:); ps2 = V(1,:);

if generateFun == 1
  vp  = S2FunHarmonicSym.quadrature(x,vp,S.CS,'bandwidth',M,'weights',W);
  vs1 = S2FunHarmonicSym.quadrature(x,vs1,S.CS,'bandwidth',M,'weights',W);
  vs2 = S2FunHarmonicSym.quadrature(x,vs2,S.CS,'bandwidth',M,'weights',W);
    
  pp = S2AxisFieldHarmonic.quadrature(x,pp,'bandwidth',M,'weights',W);
  ps1 = S2AxisFieldHarmonic.quadrature(x,ps1,'bandwidth',M,'weights',W);
  ps2 = S2AxisFieldHarmonic.quadrature(x,ps2,'bandwidth',M,'weights',W);
elseif generateFun == 2
  vp  = S2FunTri(x,vp);
  vs1 = S2FunTri(vp.tri,vs1);
  vs2 = S2FunTri(vp.tri,vs2);
  
  pp = S2AxisFieldTri(vp.tri,pp);
  ps1 = S2AxisFieldTri(vp.tri,ps1);
  ps2 = S2AxisFieldTri(vp.tri,ps2);  
end

end
