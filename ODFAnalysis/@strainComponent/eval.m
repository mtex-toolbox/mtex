function f = eval(component,ori,varargin)
% evaluate an odf at orientation ori

% align external reference frame 
% with the principal axes of the strain tensor
[rot,e] = eig(double(component.E),'vector');
%if det(rot) < 0, rot(:,1) = -rot(:,1); end
rot = rotation('matrix',rot.');
%rot = rotation.id;
%e = [0.5,0.5,-1];
%e = [0.5,-1,0.5];

% define a misorientation such that ori * mori
mori = orientation('map',component.sS.n,vector3d.X,...
  component.sS.b,vector3d.Y,component.CS,component.CS);

% Euler angles 
% in the paper these are phi, psi, theta
[phi1,phi2,Phi] = Euler(rot * ori * mori);

% 16d
F = -sin(2*phi1) .* cos(phi2);
G = sin(phi1).^2 .* cos(phi2).^2 - cos(phi1).^2;
H = -sin(phi2).^2;

% strain parameters
R12 = e(1) - e(2);
R23 = e(2) - e(3);
R31 = e(3) - e(1);

R1 = R12;
R2 = R23;
%R1 = 0; R2 = 1;

% equ (29b)
chi = atan2(R1 .* G + R2 .* H,R1 .* F) ./ 2;

% equ (29)
Gamma = sqrt(R1.^2 .* F.^2 + (R1.*G + R2.*H).^2);

% equ (28)
f = 1./ (cosh(Gamma) - sin(2*(Phi-chi)).*sinh(Gamma));

% according to Fig 5, maximum at (pi/2,0,pi/2) = 2.72
% phi1 = pi/2; Phi = 0; phi2 = pi/2;
% F = 0
% G = 0;
% H = -1;
% chi = -pi/4
% Gamma = 0.5;
% f = 1.6481
%
% this is the same as 
% phi1 = pi; Phi = 0; phi2 = 0;
% which gives
% F = 0
% G = -1;
% H = 0;
% chi = 0
% Gamma = 0;
% f = 1.6481
