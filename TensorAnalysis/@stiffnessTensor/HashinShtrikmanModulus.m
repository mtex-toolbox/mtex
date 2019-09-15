function [khs, ghs, minmax] = HashinShtrikmanModulus(C,K0,G0)
% Hashin Shtrikman moduli 
%
% The equations are from Peselnick and Meister 1965 through Watt and
% Peselnick 1980 which are based on Hashin and Shtrikman 1963 JMB 8/2013
%
% Syntax:
%
%   [khs, ghs, minmax] = HashinShtrikmanModulus(C,K0,G0)
%
% Input
%  C  - @stiffnessTensor
%  K0 - bulk modulus of the reference isotropic material
%  G0 - shear modulus of the reference isotropic material
%
% Output
%  khs - Hashin Shtrikman bulk modulus
%  ghs - Hashin Shtrikman shear modulus
%  minmax - +1 positive definite, -1 for negative definite R
%

warning('off','MATLAB:singularMatrix');
warning('off','MATLAB:illConditionedMatrix');

% ensure K0 and G0 have same size
if numel(G0) == 1, G0 = repmat(G0,size(K0)); end

% the isotropic compliances elements  (eq. 10-11 Watt Peselnick 1980)
alpha = -3 ./ (3*K0 + 4*G0);
beta = -3 * (K0 + 2*G0) ./ ( 5*G0 .* (3*K0 + 4*G0) );
gamma = (alpha - 3 * beta) ./ 9;

% set up isotropic elastic matrix 
C0 = matrix(2 * G0 .* stiffnessTensor.eye,'Voigt');

% C0 = C0 + K0 - 2/3 * G0
C0(1:3,1:3,:,:) = C0(1:3,1:3,:,:) + shiftdim(K0 - 2/3 * G0,-2);

% take difference between anisotropic and isotropic matrices and take
% inverse to get the residual compliance matrix (eq 4 & 8 Watt Peselnick 1980)
R = C - C0;
H = inv(R);


% Subtract the isotropic compliances from the residual compliance matrix
% and invert back to moduli space.  The matrix B is the moduli matrix that
% when multiplied by the strain difference between the reference isotropic
% response and the isotropic response of the actual material gives the
% average stres <pij> (eq 15 - 16 Watt Peselnick 1980) note identity matrix
% is Iinv
A = matrix(H - beta .* complianceTensor.eye,'Voigt');
A(1:3,1:3,:,:) = A(1:3,1:3,:,:) - shiftdim(gamma,-2);
B = A;
for k = 1:numel(A)/36
  B(:,:,k) = inv(A(:,:,k));
end

% now perform the averaging of the B matrix to get two numbers (B1 and B2)
% that are related to the two isotropic moduli - perturbations of the
% reference values (eq 21 and 22 Watt Peselnick 1980)
sB1 = sum(B(1:3,1:3,:,:),[1,2]);

sB2 = B(1,1,:,:) + B(2,2,:,:) + B(3,3,:,:) + 2 * (B(4,4,:,:) + B(5,5,:,:) + B(6,6,:,:));
B1 = reshape(2*sB1 - sB2,size(alpha)) / 15;
B2 = reshape(3*sB2 - sB1,size(alpha)) / 30;

% The Hashin-Shtrikman moduli are then calculated as changes from the
% reference isotropic body. (eq 25 & 27 Watt and Peselnick 1980)
khs = K0 + ( 3 * B1 + 2 * B2 ) ./ ( 3 + alpha .* (3 * B1 + 2 * B2) );
ghs = G0 + B2 ./ ( 1 + 2 * beta .* B2 );

% The moduli are valid in two limits - minimizing or maximizing the
% anisotropic difference elastic energy. Think of it as the maximum
% positive deviations from the reference state or the maximum negative
% deviations from the reference state. These are either in the positive
% definite or negative definite regime of the matrix R. Here is a test of
% the properties of R.  A +1 is returned if positive definite, a -1 is
% retunred if negative definite.  0 returned otherwise.

warning('on','MATLAB:singularMatrix');
warning('on','MATLAB:illConditionedMatrix');

minmax = zeros(size(R));
D = eig(R);
minmax(all(D>0,1)) = 1;
minmax(all(D<0,1)) = -1;
