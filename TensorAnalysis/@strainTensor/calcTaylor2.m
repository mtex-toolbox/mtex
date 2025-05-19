function [M,b,spin] = calcTaylor2(epsilon,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Since the spin tensor as solution of the Taylor model is not unique, we 
% compute the set of all optimal spin tensors for every given orientation.
% Hence we compute not only one, but all spin tensors where the energy 
% functional in the Taylor model becomes minimal.
%
% This set of optimizers is a simplex, which means that every convex 
% combination of solutions is again a solution. 
% We described the simlex by its edges.
%
% By usage of the flag 'mean' we obtain the center of gravity of the
% simplex as unique solution.
%
% Syntax
%   [MFun,~,spinFun] = calcTaylor2(eps,sS,'bandwidth',32)
%   [M,b,W] = calcTaylor2(eps,sS)
%   [M,b,W] = calcTaylor2(eps,sS,'mean')
%
% Input
%  eps - @strainTensor list in crystal coordinates
%  sS  - @slipSystem list in crystal coordinates
%
% Output
%  Mfun    - @SO3FunHarmonic (orientation dependent Taylor factor)
%  spinFun - @SO3VectorFieldHarmonic
%  M - Taylor factor
%  b - vectors of slip rates for all slip systems (We obtain the edges of the simplex of all solutions) 
%  W - @spinTensor (We obtain the edges of the simplex of all solutions) 
%
% Flags
%  mean - return not the simplex of all optimizers, but its center of gravity
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
%   [M,b,W] = calcTaylor2(inv(ori)*eps,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)
%
%
%   % compute the Taylor factor and spin Tensor w.r.t. any orientation
%   [M,~,W] = calcTaylor2(eps,sS.symmetrise)
%

% TODO: Compute the Taylor factor and strain dependent gradient independent of 
% the orientation, i.e. SO3FunHarmonic and SO3VectorFieldHarmonic



sSys = sS.ensureSymmetrised;

% find antipodal slip planes (up to sign)
eq = (norm(sSys.b + sSys.b.')==0) & (norm(sSys.n - sSys.n.')==0);
[sSi,sSi_op] = find(triu(eq));

% use every slip plane only ones
sSys = sSys(sSi);     % i.e. sS.symmetrise('antipodal')

% Energy vector
tau = sSys.CRSS(:);

% strain (right side of the constraints)
epsilon = epsilon.sym;
epsilon = reshape(epsilon.M,9,[]);
eqCons = all(~isnan(epsilon) & [1,1,1,0,1,1,0,0,0]',2); % indices of equation constraints
epsilon = epsilon(eqCons,:);

% dimensions
numCons = sum(eqCons);
numSP = length(sSys);

% Plastic deformation tensor, that is contributed by a slip plane, if it is activ (Matrix of the constraints)
sSeps = sSys.deformationTensor;
P = reshape(matrix(sSeps.sym),9,[]);
P = P(eqCons,:);

% compute all possible combinations of numCons slip planes
ind = nchoosek(1:numSP,numCons);
ind = ind';

% Solve the linear systems to find the edges of the feasible set
% List of all linear systems
A = reshape(P(:,ind(:)),numCons,numCons,[]);

% delete matrices if rank(A) < rank(A|eps)
r = pagerank(A);
Feasible = r == pagerank(cat(2, A, repmat(epsilon,1,1,size(A,3)) ));
A = A(:,:,Feasible);
ind = ind(:,squeeze(Feasible)');
if any(r(Feasible)<numCons)
  warning('The solution of some linear systems is not unique. Some solutions may disappear.')
end

% compute solution
g = pagemldivide(A,epsilon);

% corresponding Taylor factor
TF = sum(permute(tau(ind),[1,3,2]).*abs(g));
M = min(TF,[],3)';

% maybe there is nothing more to do
if nargout==1, return; end

% find edges with minimal Taylor factor
id = find(TF<1.0001*M');
[Rot_id,LS_id]=ind2sub(size(TF,[2,3]),id);
g = g(:,id);

% construct vector of edges of the simplex which is the Taylor solution
gamma = zeros(length(sSi),length(id));
gamma(ind(:,LS_id)+numSP*(0:length(id)-1)) = g;
G = zeros(2*numSP,length(id));
G(sSi,:) = max(gamma,0);
G(sSi_op,:) = max(-gamma,0);

% cluster with respect to the inputs
b = arrayfun(@(i) unique(G(:,Rot_id == i)','rows'), 1:max(Rot_id), 'UniformOutput', false);

if check_option(varargin,'num')
  b = cell2mat(cellfun(@(bi) size(bi,1),b,'UniformOutput',false))';
  return
end

if check_option(varargin,'mean')
  b = cell2mat(cellfun(@(bi) mean(bi,1)',b,'UniformOutput',false))';
elseif max(Rot_id)==1
  b = b{1};
end


% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin
% in crystal coordinates
if ~iscell(b)
  sSys2 = sS.ensureSymmetrised;
  sSeps2 = sSys2.deformationTensor;
  spin = spinTensor(b*sSeps2);
else
  spin = spinTensor(gamma'*sSeps);
  spin = arrayfun(@(i) spin(Rot_id == i), 1:max(Rot_id), 'UniformOutput', false);
end

end

function r = pagerank(A)
  s = pagesvd(A);
  tol = size(s,1) * eps(max(s, [], 1));
  r = sum(s>tol);
end