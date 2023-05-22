function [M,b,spin] = calcTaylor(eps,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Syntax
%   [MFun,~,spinFun] = calcTaylor(eps,sS,'SO3Fun','bandwidth',32)
%   [M,b,W] = calcTaylor(eps,sS)
%
% Input
%  eps - @strainTensor list in crystal coordinates
%  sS  - @slipSystem list in crystal coordinates
%
% Output
%  Mfun    - @SO3FunHarmonic (orientation dependent Taylor factor)
%  spinFun - @SO3VectorField
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
%   % compute the Taylor factor w.r.t. the given orientation
%   [M,b,W] = calcTaylor(inv(ori)*eps,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)
%
%
%   % compute the Taylor factor and spin Tensor w.r.t. any orientation
%   [M,~,W] = calcTaylor(eps,sS.symmetrise)
%

% TODO: Maybe rotate tangent space evertime to id
% Compute the Taylor factor and strain dependent gradient independent of 
% the orientation, i.e. SO3FunHarmonic and SO3VectorFieldHarmonic
if sS.CS ~= eps.CS
  bw = get_option(varargin,'bandwidth',32);
  numOut = nargout;
  F = SO3FunHandle(@(rot) calcTaylorFun(rot,eps,sS,numOut,varargin{:}),sS.CS,eps.CS);
  SO3F = SO3FunHarmonic(F,'bandwidth',bw);
  M = SO3F(1);
  if nargout>1
    b = [];
    % gradient in tangent space rotated to id
    spin = SO3VectorFieldHarmonic(SO3F(2:4));
    % gradient in tangent space at specific rotation
    % Note that this VectorField is no longer symmetric
    spin = SO3VectorFieldHandle(@(ori) inv(ori).*spin.eval(ori));
  end
  return
end


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
      b(i,:) = linprog(CRSS,[],[],A,y(:,i),zeros(size(A,2),1),[],options);
    end    
  end
  
  % display what we are doing
  if ~isSilent, progress(i,size(y,2),' computing Taylor factor: '); end
end

% the Taylor factor is simply the sum of the coefficents
M = sum(b,2) ./ norm(eps);

% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin
% in crystal coordinates
spin = spinTensor(b*sSeps.antiSym);

end



function Out = calcTaylorFun(rot,eps,sS,numOut,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [Taylor,~,spin] = calcTaylor(inv(ori)*eps,sS,varargin{:});
  s = vector3d(spin).xyz;
  Out(:,1) = Taylor;
  if numOut>1
   s = vector3d(ori.*spin).xyz;
   Out(:,2) = s(:,1);
   Out(:,3) = s(:,2);
   Out(:,4) = s(:,3);
  end
end