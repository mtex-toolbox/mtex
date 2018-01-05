function [vp,vs1,vs2,pp,ps1,ps2] = velocity(C,x,rho)
% computes the elastic wave velocity(km/s) from
% the elastic stiffness Cijkl tensor and density (g/cm3)
%
% Input
%  C   - elasticity stiffness tensor Cijkl (UNITS GPa) @tensor
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

if nargin == 1 || isempty(x)
  M = 48;
  [x, W] = quadratureS2Grid(2*M);
  generateFun = true;
else
  generateFun = false;  
end

% take density from tensor if not specified differently
if nargin == 3
elseif isfield(C.opt,'density')
  rho = C.opt.density;
else
  rho = 1;
  warning(['No density given! For computing wave velocities '...
    'the material density has to be specified. ' ...
    'I''m going to use the density rho=1.']);        
end

% compute ChristoffelTensor
E = ChristoffelTensor(C,x);

% from output
vp = zeros(size(x));
vs1 = zeros(size(x));
vs2 = zeros(size(x));
pp = zeros(3,length(x));
ps1 = zeros(3,length(x));
ps2 = zeros(3,length(x));


% for each direction
for i = 1:length(x)

  % compute eigenvalues
  [V,D] = eig(E.M(:,:,i));
  
  % compute wavespeeds
  D = sqrt(diag(D)/rho);
  
  % and sort them
  [D,ind] = sort(D);

  % the speeds
  vp(i) = D(3);
  vs1(i) = D(2);
  vs2(i) = D(1);
  
  % the polarisation axes
  pp(:,i) = V(:,ind(3));
  ps1(:,i) = V(:,ind(2));
  ps2(:,i) = V(:,ind(1));

end

pp = vector3d(pp,'antipodal');
ps1 = vector3d(ps1,'antipodal');
ps2 = vector3d(ps2,'antipodal');

if generateFun
  vp  = S2FunHarmonic.quadrature(x,vp,'bandwidth',M,'weights',W);
  vs1 = S2FunHarmonic.quadrature(x,vs1,'bandwidth',M,'weights',W);
  vs2 = S2FunHarmonic.quadrature(x,vs2,'bandwidth',M,'weights',W);
    
  %pp = S2VectorFieldHarmonic.quadrature(W.*pp,x,'m',M);
  %ps1 = S2VectorFieldHarmonic.quadrature(W.*ps1,x,'m',M);
  %ps2 = S2VectorFieldHarmonic.quadrature(W.*ps2,x,'m',M);
end