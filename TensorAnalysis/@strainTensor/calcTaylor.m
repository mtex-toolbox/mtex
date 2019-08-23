function [M,b,spin] = calcTaylor(eps,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Syntax
%   [M,b,W] = calcTaylor(eps,sS)
%
% Input
%  eps - @strainTensor list in crystal coordinates
%  sS  - @slipSystem list in crystal coordinates
%
% Output
%  M - taylor factor
%  b - vector of slip rates for all slip systems 
%  W - @spinTensor
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
%   [M,b,W] = calcTaylor(inv(ori)*eps,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)

% ensure strain is symmetric
eps = eps.sym;

% compute the deformation tensors for all slip systems
sSeps = sS.deformationTensor;

% initalize the coefficients
b = zeros(length(eps),length(sS));

% critical resolved shear stress - CRSS
% by now assumed to be identical - might also be stored in sS
CRSS = sS.CRSS(:);%ones(length(sS),1);

% decompose eps into sum of disclocation tensors, that is we look for
% coefficients b such that sSepsSym * b = eps

% since the strain tensor is symmetric we require only 5 entries out of it
A = reshape(matrix(sSeps.sym),9,[]);
A = A([1,2,3,5,6],:);

% the strain coefficients to match
y = reshape(eps.M,9,[]);
y = y([1,2,3,5,6],:);

% this method applies the dual simplex algorithm 
if getMTEXpref('mosek',false)
  param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_INTPNT';
  param.MSK_IPAR_INTPNT_BASIS = 'MSK_BI_NEVER';
  %param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1.0e-3;  
else
  %options = optimoptions('linprog','Algorithm','dual-simplex','Display','none');
  options = optimoptions('linprog','Algorithm','interior-point-legacy','Display','none');
end

% shall we display what we are doing?
isSilent = check_option(varargin,'silent');

% for all strain tensors do
for i = 1:size(y,2)
  
  % determine coefficients b with A * b = y and such that sum |CRSS_j *
  % b_j| is minimal. This is equivalent to the requirement b>=0 and CRSS*b
  % -> min which is the linear programming problem solved below
  try
    if getMTEXpref('mosek',false)
      res = msklpopt(CRSS,A,y(:,i),y(:,i),zeros(size(A,2),1),inf(size(A,2),1),...
        param,'minimize echo(0)');
      b(i,:) = res.sol.itr.xx;
    else
      b(i,:) = linprog(CRSS,[],[],A,y(:,i),zeros(size(A,2),1),[],[],options);
    end    
  end
  
  % display what we are doing
  if ~isSilent, progress(i,size(y,2),' computing Taylor factor: '); end
end

% the Taylor factor is simply the sum of the coefficents
M = sum(b,2);

% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin
% in crystal coordinates
spin = spinTensor(b*sSeps.antiSym);

end
