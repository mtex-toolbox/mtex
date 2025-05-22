function [M,b,spin] = calcTaylor1(eps,sS,varargin)
% compute the Taylor factor, Burgers vector and strain dependent 
% orientation spin by computing exactly one feasible solution of the linear
% program (Taylor model) with interior-point-method or the simplex algorithm.


% ensure slip systems are symmetrised including +- of each slipSystem
sS = sS.ensureSymmetrised;

% ensure strain is symmetric
eps = eps.sym;

% compute the deformation tensors for all slip systems
sSeps = sS.deformationTensor;

% initialize the coefficients
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
      b(i,:) = linprog(CRSS,[],[],A,y(:,i),zeros(size(A,2),1),[],options);
    end    
  end
  
  % display what we are doing
  if ~isSilent, progress(i,size(y,2),' computing Taylor factor: '); end
end

% the Taylor factor is simply the sum of the coefficents
M = reshape(sum(b,2),size(eps)) ./ norm(eps);

% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin
% in crystal coordinates
spin = spinTensor(b*sSeps);

end

