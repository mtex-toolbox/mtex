function [M,b,spin] = calcTaylorAll(epsilon,sS,varargin)
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
%  uniqueTol - unite all edges that are simmilar w.r.t. this tolerance
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
  warning('The solutions of some linear systems are not unique. Some solutions may disappear.')
end

% compute solution
g = pagemldivide(A,epsilon);

% corresponding Taylor factor
TF = sum(permute(tau(ind),[1,3,2]).*abs(g));
M = min(TF,[],3)';

% maybe there is nothing more to do
if nargout<=1, return; end

% Compute Burgers vector and spin tensors:
%     - Mean: uTol = tol = 1e-9
%     - Inverse Distance: uTol=-1; tol = ...

% find edges with minimal Taylor factor
tol = get_option(varargin,'inverseDistance',max(get_option(varargin,'uniqueTol',1e-9),0));

id = find(TF<=(1+tol)*M');
[Rot_id,LS_id]=ind2sub(size(TF,[2,3]),id);
g = g(:,id);

% construct vector of edges of the simplex which is the Taylor solution
gamma = zeros(length(sSi),length(id));
gamma(ind(:,LS_id)+numSP*(0:length(id)-1)) = g;
G = zeros(2*numSP,length(id));
G(sSi,:) = max(gamma,0);
G(sSi_op,:) = max(-gamma,0);

% unite edges that occur several times in the solution simplex of an orientation
uTol = get_option(varargin,'uniqueTol',1e-9);
if uTol>=0
  G = [Rot_id';G];
  % TODO: Data scale with respect to tau*M
  [G,IA] = uniquetol(G',uTol,'byRows',true,'DataScale',max( max(abs(g(:))) , 1 ) );
  Rot_id = G(:,1);
  id = id(IA);
  G = G(:,2:end)';
end

% if number of edges of the simplex is observed
if check_option(varargin,'numberOfEdges')
  b = histc(Rot_id,1:max(Rot_id));
  return
end

% Cluster Solutions into cell array
b = accumarray(Rot_id, (1:length(Rot_id))', [], @(x) {G(:,x)'})';


% TODO: This can be done better
if check_option(varargin,'inverseDistance')
  TF = squeeze(TF(id));
  % cluster with respect to the inputs
  w = arrayfun(@(i) 1 - (TF(Rot_id == i)-M(i))/(M(i)*tol) , 1:max(Rot_id), 'UniformOutput', false);
  b = cell2mat(cellfun(@(bi,wi) sum(wi.*bi,1)'/sum(wi)  ,b,w,'UniformOutput',false))';
elseif check_option(varargin,'mean')
  % unstetig an Stellen, wo sich Anzahl der Ecken des Simplex ändert
  b = cell2mat(cellfun(@(bi) mean(bi,1)',b,'UniformOutput',false))';
end


% maybe there is nothing more to do
if nargout <=2, return; end

% the antisymmetric part of the deformation tensors gives the spin
% in crystal coordinates
sSys2 = sS.ensureSymmetrised;
sSeps2 = sSys2.deformationTensor;
if ~iscell(b)
  spin = spinTensor(b*sSeps2);
else
  % TODO: Speed up
  spin = cellfun(@(bi) spinTensor(bi*sSeps2) , b, 'UniformOutput', false);
end

end

function r = pagerank(A)
  s = pagesvd(A);
  tol = size(s,1) * eps(max(s, [], 1));
  r = sum(s>tol);
end
