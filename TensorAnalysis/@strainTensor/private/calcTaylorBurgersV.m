function b = calcTaylorBurgersV(eps,sS,spin,varargin)
% compute the Taylor factor and the simplex of all feasible solutions of 
% the linear program (Taylor model).
%
% Afterwards we compute the Burgers vector and strain dependent orientation 
% spin as mean vector of the simplex or by inverse distancing.
%
% Syntax
%   [~,NoE] = calcTaylor(eps,sS,'numberOfEdges');
%   [M,b,W] = calcTaylor(eps,sS)
%   [M,b,W] = calcTaylor(eps,sS,'inverseDistance',0.01,'uniqueTol',1e-9)
%
% Input
%  eps - @strainTensor list in crystal coordinates
%  sS  - @slipSystem list in crystal coordinates
%
% Output
%  NoE - Number of edges of the simplex that describes the optimal set
%  M - taylor factor
%  b - vector of slip rates for all slip systems 
%  W - @spinTensor
%
% Options
%  inverseDistance - edges are optimal if there corresponding minimal value <= (1+tol)*M. Moreover b is the inverse-distance weighted mean of the simplex.
%  tolerance - obtain all edges, which taylor factor is minimal w.r.t. this tolerance
%
% Flags
%  'numberOfEdges' - Obtain the number of edges of the optimal set (simplex)
%

sSys = sS.ensureSymmetrised;

% find antipodal slip planes (up to sign)
eq = (norm(sSys.b + sSys.b.')==0) & (norm(sSys.n - sSys.n.')==0);
[sSi,sSi_op] = find(triu(eq));

% use every slip plane only ones
sSys = sSys(sSi);     % i.e. sS.symmetrise('antipodal')

% Energy vector
tau = sSys.CRSS(:);

% strain (right side of the constraints)
eps = eps.sym;
epsilon = reshape(eps.M,9,[]);
if any(isnan(epsilon))
  error('Relaxed Model is not implemented yet.') 
end
epsilon = epsilon([1,2,3,5,6],:);

% dimensions
numSP = length(sSys);

% Plastic deformation tensor, that is contributed by a slip plane, if it is activ (Matrix of the constraints)
sSeps = sSys.deformationTensor;
P = reshape(matrix(sSeps.sym),9,[]);
P = P([1,2,3,5,6],:);

% the antisymmetric part of the deformation tensors gives the spin in crystal coordinates
Q = reshape(matrix(sSeps.antiSym),9,[]);
Q = Q([6,7,2],:);

% compute all possible combinations of numCons slip planes
ind = nchoosek(1:numSP+1,8);
ind = ind';

% Solve the linear systems to find the edges of the feasible set
% List of all linear systems
sigma = spin.xyz;
M = [P,[0,0,0,0,0]';Q,sigma'];
A = reshape(M(:,ind(:)),8,8,[]);

% delete matrices if rank(A) < 5
% Most of these matrices are infeasible, if rank(A) < rank(A|b).
% If b is unfortunately selected and it yields rank(A) = rank(A|b) < 5, then the 
% solutions can be obtained by substituting one of the dependent columns of A 
% with an independent column of P. This column will be inactive in the solution 
% since epsilon is in the span of A.
% The Substituted Matrix is allready contained in the array.
Feasible = pagerank(A) == 8;
A = A(:,:,Feasible);
ind = ind(:,squeeze(Feasible)');

% compute solution
g = pagemldivide(A,[epsilon;0;0;0]);

% corresponding Taylor factor
tau = [tau;0];
TF = sum(permute(tau(ind),[1,3,2]).*abs(g));
M = min(TF,[],3)'./norm(eps);

% Compute Burgers vector and spin tensors:
%     - Mean: uTol = tol = 1e-9
%     - Inverse Distance: uTol=-1; tol = ...

% find edges with minimal Taylor factor
tol = max(get_option(varargin,'tolerance',1e-9),0);

id = find(TF<=(1+tol)*M');
[Rot_id,LS_id]=ind2sub(size(TF,[2,3]),id);
g = g(:,id);

% construct vector of edges of the simplex which is the Taylor solution
gamma = zeros(length(sSi)+1,length(id));
gamma(ind(:,LS_id)+(numSP+1)*(0:length(id)-1)) = g;
gamma(end,:) = [];
G = zeros(2*numSP,length(id));
G(sSi,:) = max(gamma,0);
G(sSi_op,:) = max(-gamma,0);

% unite edges that occur several times in the solution simplex of an orientation
G = [Rot_id';G];
[G,IA] = uniquetol(G',1e-6,'byRows',true,'DataScale', max(max(abs(G')),1) );
Rot_id = G(:,1);
id = id(IA);
G = G(:,2:end)';

% Cluster Solutions into cell array
b = accumarray(Rot_id, (1:length(Rot_id))', [], @(x) {G(:,x)'})';

end

function r = pagerank(A)
  s = pagesvd(A);
  tol = size(s,1) * eps(max(s, [], 1));
  r = sum(s>tol);
end
