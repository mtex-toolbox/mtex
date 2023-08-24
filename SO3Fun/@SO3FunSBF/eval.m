function f = eval(SO3F,ori,varargin)
% evaluate an odf at orientation ori

% change evaluation method to quadratureSO3Grid.eval
if isa(ori,'quadratureSO3Grid')
  f = quadratureSO3Grid.eval(SO3F,ori,varargin{:});
  return
end

% align external reference frame 
% with the principal axes of the strain tensor
[rot,e] = eig(double(SO3F.E),'vector');
rot = rotation.byMatrix(rot.');

% define a misorientation such that ori * mori
% alignes slip normal n with X and slip direction d with Y
mori = orientation.map(SO3F.sS.n,SO3F.CS.Y,...
  SO3F.sS.b,SO3F.CS.X);

% Euler angles 
% in the paper these are phi, theta, psi
[phi1,Phi,phi2] = Euler(rot * ori * mori,'Bunge');

% 16d
F = -sin(2*phi1) .* cos(Phi);
G = sin(phi1).^2 .* cos(Phi).^2 - cos(phi1).^2;
H = -sin(Phi).^2;

% strain parameters
R12 = e(1) - e(2);
R23 = e(2) - e(3);
R31 = e(3) - e(1);

R1 = R12;
R2 = R23;

% equ (29b)
chi = atan2(R1 .* G + R2 .* H,R1 .* F) ./ 2;

% equ (29)
Gamma = sqrt(R1.^2 .* F.^2 + (R1.*G + R2.*H).^2);

% equ (28)
f = 1./ (cosh(Gamma) - sin(2*(phi2-chi)).*sinh(Gamma));
