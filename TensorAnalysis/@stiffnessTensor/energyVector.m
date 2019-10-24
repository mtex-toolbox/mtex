function E = energyVector(C,x,V,P,varargin)
% Calculates Energy velocity vector (km/s)
%
% Description
% Energy velocity for lossless elastic medium (i.e. no attenuation)
% Good proxy for group velocity, which typically has some energy loss
% The formula is given by
% F.I. Fedorov(1968)Theory of Elastic Waves in Crystals, 375 pp. New York: Penum Press.
%
% Ve_i = C_ijkl P_j P_l X_k / rho*V
% 
% N.B. E_magnitude should be equal or more than plane wave velocity vp, vs1 or vs2
% 
% David Mainprice 6/02/2018
%
% Syntax
%   E = energyVector(C,x,v,p)
%   E = energyVector(C,x,v,p,rho)
%   E = energyVector(C,[],vFun,pFun)
%   E = energyVector(C,[],vFun,pFun,rho)
%
% Input
%  C - @stiffnessTensor (units GPa)
%  x - @vector3d propagation direction 
%  v - plane wave velocity (unit km/s) e.g. vp,vs1 or vs2 
%  p - @vector3d plane wave polarization vector e.g. pp,ps1 or ps2
%  vFun - @S2Fun plane wave velocity (unit km/s) e.g. vp,vs1 or vs2 
%  pFun - @S2AxisField plane wave polarization vector e.g. pp,ps1 or ps2
%  rho - density in g/cm3
%
% Output
%  E - Energy velocity vector (units km/s)
%


% return a function if required
if isempty(x)
  if isa(V,'S2FunTri')
    E = S2VectorFieldTri(V.tri,energyVector(C,V.vertices,V.values,P.values,varargin{:}));
  else
    E = S2VectorFieldHarmonic.quadrature(@(x) energyVector(C,x,V,P,varargin{:}),'bandwidth',128,C.CS);
  end
  return
end

% make X and P to be unit vectors
x = x.normalize;

if ~isa(P,'vector3d'), P = P.eval(x); end
if ~isnumeric(V), V = V.eval(x); end
P = P.normalize;

% get density
if nargin == 5
  rho = varargin{1};
elseif isfield(C.opt,'density')
  rho = C.opt.density;
else
  rho = 1;
  warning('No density given! I''m going to use the density rho=1.');        
end

% E_vector
E = vector3d(EinsteinSum(C,[1 -2 -3 -4],P(:),-2,P(:),-4,x(:),-3))./rho ./V(:);

end