function [khs, ghs, def] = HashinShtrikmanModulus(C,Ko,Go)
% Hashin Shtrikman moduli 
%
% Description
% The equations are from Peselnick and Meister 1965 through Watt and
% Peselnick 1980 which are based on Hashin and Shtrikman 1963 JMB 8/2013
%
% Syntax:
%
%   [khs, ghs, def] = HashinShtrikmanModulus(C,Ko,Go)
%
% Input
%  C  - @stiffnessTensor
%  Ko - bulk modulus of the reference isotropic material
%  Go - shear modulus of the reference isotropic material
%
% Output
%  khs - Hashin Shtrikman bulk modulus
%  ghs - Hashin Shtrikman shear modulus
%  def - +1 positive definite, -1 for negative definite R
%

% ensure K0 and G0 have same size
if numel(Go) == 1, Go = repmat(Go,size(Ko)); end

% the isotropic compliances elements (eq. 10-11 Watt Peselnick 1980)
alpha = -3 ./ (3*Ko + 4*Go);
beta = -3 * (Ko + 2*Go) ./ ( 5*Go .* (3*Ko + 4*Go) );
gamma = (alpha - 3 * beta) ./ 9;

% define the isotropic tensor corresponding to Ko and Go
Co = 2 * Go .* stiffnessTensor.eye + (Ko - 2/3 * Go) .* dyad(tensor.eye,tensor.eye);

% take difference between anisotropic and isotropic matrices and take
% inverse to get the residual compliance matrix (eq 4 & 8 Watt Peselnick 1980)
R = C - Co;
H = inv(R);

% Subtract the isotropic compliances from the residual compliance matrix
% and invert back to moduli space.  The matrix B is the moduli matrix that
% when multiplied by the strain difference between the reference isotropic
% response and the isotropic response of the actual material gives the
% average stres <pij> (eq 15 - 16 Watt Peselnick 1980).
A = H - beta .* complianceTensor.eye - gamma .* dyad(tensor.eye,tensor.eye);
B = inv(A);


% now perform the averaging of the B matrix to get two numbers (B1 and B2)
% that are related to the two isotropic moduli - perturbations of the
% reference values (eq 21 and 22 Watt Peselnick 1980)
sB1 = EinsteinSum(B,[-1 -1 -2 -2]);
sB2 = EinsteinSum(B,[-1 -2 -1 -2]);

B1 = (2*sB1 - sB2) / 15;
B2 = (3*sB2 - sB1) / 30;

% The Hashin-Shtrikman moduli are then calculated as changes from the
% reference isotropic body. (eq 25 & 27 Watt and Peselnick 1980)
khs = Ko + ( 3 * B1 + 2 * B2 ) ./ ( 3 + alpha .* (3 * B1 + 2 * B2) );
ghs = Go + B2 ./ ( 1 + 2 * beta .* B2 );

% The moduli are valid in two limits - minimizing or maximizing the
% anisotropic difference elastic energy. Think of it as the maximum
% positive deviations from the reference state or the maximum negative
% deviations from the reference state. These are either in the positive
% definite or negative definite regime of the matrix R. Here is a test of
% the properties of R.  A +1 is returned if positive definite, a -1 is
% retunred if negative definite.  0 returned otherwise.

def = zeros(size(R));
D = eig(R);
def(all(D>0,1)) = 1;
def(all(D<0,1)) = -1;

% isf minmax == 0 this means ...
khs(def==0) = NaN;
ghs(def==0) = NaN;
