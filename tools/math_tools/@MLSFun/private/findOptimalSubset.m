function sub = findOptimalSubset(F,ind,v,varargin)
% the dim neighbors of every center that minimize the Lebesgue constant
%
% Input
%  F   - @S2FunMLS, @SO3FunMLS
%  ind - N × nn indices into F.nodes, or N × numel(F.nodes) logical incidence
%  v   - centers
%
% Output
%  sub - the optimal subsets in the format of ind, dim nodes per center
%
% Options
%  threads - number of parallel workers (default 1)
%
% Description
% The subset is read off the linear program that maximizes p(0) over all
% polynomials p of the ansatz with |p(x_i)| <= 1/w(x_i): the dim constraints
% with the largest multipliers are the active ones.

N = size(ind,1);
isLogical = islogical(ind);
if ~isLogical
  ind = sparse(repmat((1:N).',1,size(ind,2)),ind,true,N,numel(F.nodes));
end

% all neighbors in local coordinates, center by center in ascending node order
[gridId,centerId] = find(ind.');
[M,c] = localBasis(F,v,centerId,gridId);
dist = angle(F.nodes.subSet(gridId),v.subSet(centerId));
last = cumsum(full(sum(ind,2)));
first = [1; last(1:end-1) + 1];

options = linprogOptions;
margin = F.supportMargin;
dim = F.dim;
w = F.w;
sub = zeros(N,dim);

numThreads = get_option(varargin,'threads',1,'double');
if numThreads == 1
  for i = 1:N
    rows = first(i):last(i);
    sub(i,:) = gridId(rows(optimalRows(M(rows,:),dist(rows),w,margin,c,options,dim)));
  end
else
  parfor (i = 1:N, numThreads)
    rows = first(i):last(i);
    sub(i,:) = gridId(rows(optimalRows(M(rows,:),dist(rows),w,margin,c,options,dim)));
  end
end

if isLogical
  sub = sparse(repmat((1:N).',1,dim),sub,true,N,numel(F.nodes));
end

end


function id = optimalRows(halfM,dist,w,margin,c,options,dim)
% the rows of the dim constraints with the largest multipliers

b = repmat(1 ./ w(dist ./ (max(dist) * margin)),2,1);
[~,~,~,~,lambda] = linprog(c,[halfM;-halfM],b,[],[],[],[],options);

% the upper and lower bound of a node pair up; numerically most multipliers
% are small rather than exactly zero, so take the largest ones
[~,id] = sort(max(abs(reshape(lambda.ineqlin,[],2)),[],2),'descend');
id = id(1:dim);

end


function options = linprogOptions
% linprog options that return the Lagrange multipliers
%
% The simplex algorithms are the faster ones, but on some releases they fail
% as soon as the multipliers are requested. One trivial program, whose
% solution is a vertex, decides once per session.

persistent cached
if ~isempty(cached), options = cached; return, end

options = optimoptions('linprog','Display','none');
ws = warning('off','all');
try
  [~,~,~,~,~] = linprog([-1;-1],[1 0;0 1;1 1],[1;1;1.5],[],[],[],[],options);
catch
  options = optimoptions('linprog','Display','none','Algorithm','interior-point-legacy');
  warning(ws);
  warning('MTEX:linprog:algorithm', ...
    ['linprog was set to use interior-point-legacy, since the simplex ' ...
    'algorithms of this MATLAB release do not return the Lagrange ' ...
    'multipliers the optimal subset selection needs.']);
end
warning(ws);

cached = options;

end
