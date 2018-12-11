function [M,b,eps] = calcInvTaylor(mori,sS,varargin)
% Taylor factor from orientation gradient
%
% Syntax
%   [M,b,eps] = calcInvTaylor(mori,sS)
%
% Input
%  mori - mis@orientation
%  sS   - @slipSystem list in crystal coordinates
%
% Output
%  M    - taylor factor
%  b    - coefficients for the acive slip systems
%  eps  - strain @tensor list in crystal coordinates
%
% Example
%
%   % define 10 percent strain
%   eps = 0.1 * strainTensor(diag([1 -0.75 -0.25]))
%
%   % define a crystal orientation
%   cs = crystalSymmetry('cubic')
%   ori = orientation.byEuler(0,30*degree,15*degree,cs)
%
%   % define a slip system
%   sS = slipSystem.fcc(cs)
%
%   % compute the Taylor factor
%   [M,b,mori] = calcTaylor(inv(ori)*eps,sS.symmetrise)
%

% compute the deformation tensors for all slip systems
dT = sS.deformationTensor;

% initalize the coefficients
b = zeros(length(mori),length(sS));

% the antisymmetric part of the deformation tensors give the misorientation
R = reshape(matrix(dT.antiSym),9,[]);
R = [R(6,:);-R(3,:);R(2,:)];

% critical resolved shear stress - CRSS
% by now assumed to be identical - might also be stored in sS
CRSS = ones(length(sS),1);

% the orientation gradient tensor to match
y = reshape(double(log(mori)),[],3).';

% this method applies the dual simplex algorithm
options = optimoptions('linprog','Algorithm','dual-simplex','Display','none');
%options = optimoptions('linprog','Algorithm','interior-point','Display','none');

% shall we display what we are doing?
isSilent = check_option(varargin,'silent');

% for all misorientations do
for i = 1:size(y,2)

  % determine coefficients b with R * b = y and such that sum |b_j| is
  % minimal. This is equivalent to the requirement b>=0 and 1*b -> min
  % which is the linear programming problem solved below
  b(i,:) = linprog(CRSS,[],[],R,y(:,i),zeros(size(R,2),1),[],[],options);

  % display what we are duing
  if ~isSilent, progress(i,size(y,2),' computing Taylor factor: '); end
end

% the inv Taylor factor is simply the sum of the coefficents
M = sum(b,2);

% maybe there is nothing more to do
if nargout <=2, return; end

% the symmetric part of the deformation tensor will become the strain
eps = b * dT.sym;
