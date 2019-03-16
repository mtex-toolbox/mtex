function [M,b,spin] = calcTaylor(L,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Syntax
%   [M,b,W] = calcTaylor(eps,sS)
%
% Input
%  L  - @velocityGradientTensor
%  sS - @slipSystem
%
% Output
%  M - taylor factor
%  b - coefficients for the acive slip systems
%  W - @spinTensor
%
% Example
%
%   % consider uniaxial tension in (100) direction about 30 percent
%   F = deformationGradientTensor.uniaxial(vector3d.X,1.3)
%
%   % the corresponding rate of deformation tensor becomes
%   L = logm(F)
%
%   % define a crystal orientation
%   cs = crystalSymmetry('cubic')
%   ori = orientation.byEuler(0,30*degree,15*degree,cs)
%
%   % define a slip system
%   sS = slipSystem.fcc(cs)
%
%   % compute the Taylor factor
%   [M,b,spin] = calcTaylor(inv(ori)*L,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)

% the antisymmetry part of the strainRateTensor is directly the spin increment
spin = L.antiSym;

% the symmetric part is the strain increment
E = L.sym;

% compute the deformation tensors for all slip systems
E_sS = sS.deformationTensor;

% initalize the coefficients
b = zeros(length(E),length(sS));

% critical resolved shear stress - CRSS
% by now assumed to be identical - might also be stored in sS
CRSS = sS.CRSS(:);%ones(length(sS),1);

% decompose E into sum of deformation tensors, i.e., we look for
% coefficients b such that E_sS * b = E

% since the strain tensor is symmetric we require only 5 entries out of it
A = reshape(matrix(E_sS.sym),9,[]);
A = A([1,2,3,5,6],:);

% the strain coefficients to match
y = reshape(E.M,9,[]);
y = y([1,2,3,5,6],:);

% this method applies the dual simplex algorithm
%options = optimoptions('linprog','Algorithm','dual-simplex','Display','none');
options = optimoptions('linprog','Algorithm','interior-point-legacy','Display','none');

% shall we display what we are doing?
isSilent = check_option(varargin,'silent');

% for all strain tensors do
for i = 1:size(y,2)

  % determine coefficients b with A * b = y and such that sum |CRSS_j *
  % b_j| is minimal. This is equivalent to the requirement b>=0 and CRSS*b
  % -> min which is the linear programming problem solved below
  try
    b(i,:) = linprog(CRSS,[],[],A,y(:,i),zeros(size(A,2),1),[],[],options);
  end
  % display what we are doing
  if ~isSilent, progress(i,size(y,2),' computing Taylor factor: '); end
end

% the Taylor factor is simply the sum of the coefficents
M = sum(b,2);

% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin in
% crystal coordinates
spin = spinTensor(b*E_sS.antiSym);
