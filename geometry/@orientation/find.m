function [ind,d] = find(v,w,epsilon_or_k,varargin)
% return index of all points in an epsilon neighborhood of a vector
%
% Syntax
%   ind = find(v,w)         % find closest point out of v to w
%   ind = find(v,w,epsilon) % find all points out of v in an epsilon neighborhood of w
%   ind = find(v,w,k)       % find k nearest points out of v to w
%
% Input
%  v, w         - @orientation
%  epsilon_or_k - epsilon or k (see below), depending on what the user wants
%  epsilon      - double
%  k            - int32
%
% Output
%  ind          - numel(w) x k array of *distinct* indices into v for k
%                 nearest neighbors,
%               - numel(w) x numel(v) sparse logical incidence matrix for
%                 region search
%  d            - numel(w) x k double array for k nearest neighbors,
%               - numel(w) x numel(v) sparse double array for region search
%                 (0 whenever ind is 0)
%
% Note that antipodal symmetry is taken from v.antipodal, there is no
% 'antipodal' option.
%

if nargin==2, epsilon_or_k=1; end

% k is documented as int32 - cast it, as integer types do not survive the
% arithmetic below
epsilon_or_k = double(epsilon_or_k);

v = reshape(v, [], 1);
w = reshape(w, [], 1);

if ~isa(w,'orientation')
  w = orientation(w,v.CS,v.SS);
end

v.CS = v.CS.properGroup;
v.SS = v.SS.properGroup;
w.CS = w.CS.properGroup;
w.SS = w.SS.properGroup;

% Check for matching symmetries. Note that == on a crystalSymmetry is handle
% identity (see phaseItem.m, where eq is sealed) - eqTol is the comparison
% that asks for the same Laue group and the same axes.
if ~all(eqTol(v.CS,w.CS)) || ~all(eqTol(v.SS,w.SS))
  error('MTEX:find:symmetryMismatch','The symmetries have to coincide.')
end

% Only one symmetry can be used in the find-method. If both are non trivial
% fold the smaller one into the data set v and search with the larger one.
if v.CS.numSym>1 && v.SS.numSym>1
  [ind,d] = findFold(v,w,epsilon_or_k,varargin{:});
  return
end

v = orientation(v.subSet(':'));
w = orientation(w);
nV = length(v);   % keep it, v is overwritten by its symmetrisation below

% compute fundamental Region
ap ={};
if v.antipodal
  ap={'antipodal'};
end
fR = fundamentalRegion(v.CS,v.SS,ap{:});

% decide for tolerance epsilon
isK = (floor(epsilon_or_k) == epsilon_or_k);
if isK
  if epsilon_or_k > nV
    error('MTEX:find:tooManyNeighbours',...
      'Cannot search for the %d nearest points out of only %d.',epsilon_or_k,nV)
  end
  if check_option(varargin,'worstCaseError')
    epsilon = fR.maxAngle/2;
  else
    % expected epsilon for uniform distributed points
    V = 1/v.CS.numSym/v.SS.numSym/(1+v.antipodal);
    epsilon = (6*pi*epsilon_or_k*V/length(v))^(1/3);
    epsilon = 2*epsilon; % use slightly greater range
  end
else
  epsilon = epsilon_or_k;
end

% project v to fundamental region with some band of tolerance omega
v0 = v;             % the unsymmetrised points, needed for the fallback below
v = v.symmetrise;
id = fR.checkInside(v,'tolerance',epsilon+1e-4);
v = v.subSet(id);
v = v.subSet(':');
[~,id] = find(id);  % x = id.*(1:10000); x(id);
id = id(:);         % a column, so that id(ind) keeps the shape of ind

% w project to fundamental region
wq = quaternion(project2FundamentalRegion(w));
vq = quaternion(v);

if isK

  % a point of v may have several copies inside the tolerance band of the
  % fundamental region. Ask for enough candidates so that k *distinct*
  % points of v remain once the copies are mapped back.
  if isempty(id), mult = 1; else, mult = max(accumarray(id,1)); end
  kSub = min(epsilon_or_k * mult, numel(id));

  % find points on fundamental region
  [ind,d] = find@quaternion(vq,wq,kSub,varargin{:});
  ind = id(ind);
  [ind,d] = collapseK(ind,d,epsilon_or_k);

  % determine not correctly classified points and search again for them
  nCC = max(d,[],2) > min(pi-angle(wq,fR.N) + epsilon,[],2);
  % nCC is empty when the fundamental region is unbounded, i.e. fR.N is empty
  if any(nCC(:)) && ~check_option(varargin,'worstCaseError')
    if nnz(nCC)<100
      [d2,ind2] = mink(angle(w.subSet(nCC),v0.'),epsilon_or_k,2);
    else
      [ind2,d2] = find(v0,w.subSet(nCC),epsilon_or_k,'worstCaseError');
    end
    ind(nCC,:) = ind2;
    d(nCC,:) = d2;
  end

else

  % find points on fundamental region
  [ind,d] = find@quaternion(vq,wq,epsilon_or_k,varargin{:});
  [ind,d] = collapseEps(ind,d,id,nV);

end

end

% -------------------------------------------------------------------------
function [ind,d] = findFold(v,w,epsilon_or_k,varargin)
% Fold the smaller of the two symmetry groups into the data set v, so that
% the actual search has to deal with a single non trivial symmetry only.

N = length(v);
cs = v.CS; ss = v.SS;
ws = w;

% antipodal requires CS == SS, which the fold destroys. Keep the inverted
% points around, they are folded into the data set below - then the search
% itself does not have to deal with antipodal at all.
vi = v;
if v.antipodal
  vi = inv(v); vi.CS = v.CS; vi.SS = v.SS; vi.antipodal = false;
end

if numSym(cs) >= numSym(ss)
  % fold the specimen symmetry into the data, search with the crystal one
  nRep = numSym(ss);
  vs = ss*v;                     % numSym(ss) x N

  if v.antipodal
    vs = [vs; ss*vi];            % 2*numSym(ss) x N
    nRep = 2*nRep;
  end

  triv = specimenSymmetry;       % not specimenSymmetry.default - that one
  vs.SS = triv; ws.SS = triv;    % is a singleton the user may have changed
  vs.antipodal = false; ws.antipodal = false;
else
  % fold the crystal symmetry into the data, search with the specimen one
  nRep = numSym(cs);
  vs = (v*cs).';                 % (N x numSym(cs)).' = numSym(cs) x N
  triv = crystalSymmetry('1');
  vs.CS = triv; ws.CS = triv;
end

% both branches are numSym x N, so the column major linearisation groups the
% nRep copies of each point of v together
assert(numel(vs) == nRep*N && size(vs,1) == nRep,'MTEX:find:layout',...
  'unexpected layout of the symmetrised orientations')
vs = reshape(vs,[],1);
origIdx = repelem((1:N).',nRep,1);

if floor(epsilon_or_k) == epsilon_or_k

  % the k nearest distinct points of v are among the k*nRep nearest copies:
  % any copy beating the i-th ranked point belongs to one of the i-1 <= k-1
  % better points, which contribute at most (k-1)*nRep < k*nRep copies
  kSub = min(epsilon_or_k * nRep, numel(vs));

  [ind,d] = find(vs,ws,kSub,varargin{:});
  ind = origIdx(ind);
  [ind,d] = collapseK(ind,d,epsilon_or_k);

  % rows that did not yield k distinct points - fall back to brute force.
  % Note that angle() ignores the antipodal flag, so the inversion has to be
  % taken into account explicitly here as well.
  bad = any(~isfinite(d),2);
  if any(bad)
    dRef = angle(w.subSet(bad),v.');
    if v.antipodal, dRef = min(dRef,angle(w.subSet(bad),vi.')); end
    [d(bad,:),ind(bad,:)] = mink(dRef,epsilon_or_k,2);
  end

else

  [ind,d] = find(vs,ws,epsilon_or_k,varargin{:});
  [ind,d] = collapseEps(ind,d,origIdx,N);

end

end

% -------------------------------------------------------------------------
function [ind,d] = collapseK(ind,d,k)
% Reduce the candidates ind / d to the k nearest *distinct* entries of ind.
% Rows with fewer than k distinct entries are padded with 0 / Inf.

[M,kSub] = size(ind);

% do not rely on the search returning its candidates sorted
[d,p] = sort(d,2);
rows = repmat((1:M).',1,kSub);
ind = ind(sub2ind([M kSub],rows,p));

% sort is stable, hence within a run of equal indices the first one carries
% the smallest distance - diff == 0 flags exactly the redundant candidates
[indS,ord] = sort(ind,2);
isRep = [false(M,1), diff(indS,1,2)==0];
rep = false(M,kSub);
rep(sub2ind([M kSub],rows,ord)) = isRep;

keep = ~rep;
pos = cumsum(keep,2);      % target column of every kept candidate
sel = keep & pos <= k;

lin = find(sel);
[r,~] = ind2sub([M kSub],lin);
newInd = zeros(M,k); newD = inf(M,k);
tgt = sub2ind([M k],r,pos(lin));
newInd(tgt) = ind(lin);
newD(tgt) = d(lin);

ind = newInd; d = newD;

end

% -------------------------------------------------------------------------
function [ind,d] = collapseEps(ind,d,map,nOut)
% Collapse the columns of the incidence matrix ind and of the distance
% matrix d onto nOut original points. Columns that collapse onto the same
% point keep the *smallest* distance - ind*map would sum them up instead.

M = size(ind,1);

% take the triplets from ind, not from d: a sparse d does not store an exact
% zero distance, which is precisely the case of w sitting on a point of v
[r,c] = find(ind);
if isempty(r)
  ind = logical(sparse(M,nOut));
  d = sparse(M,nOut);
  return
end
r = r(:); c = c(:);
% d(...) follows the orientation of d when d is a vector, hence the reshape
dv = reshape(full(d(sub2ind(size(d),r,c))),[],1);
c = reshape(map(c),[],1);

% keep the minimum per (row,column) pair
key = (c-1)*M + r;
[~,p] = sortrows([key dv]);
r = r(p); c = c(p); dv = dv(p); key = key(p);
first = [true; diff(key)~=0];

% build ind and d from the same triplets, so that d is 0 exactly where ind is
ind = sparse(r(first),c(first),true,M,nOut);
d = sparse(r(first),c(first),dv(first),M,nOut);

end

function test

% construct data
cs = crystalSymmetry('321');
ss = crystalSymmetry('222');
ap = {};

omega = 1*degree;
K=4;

rng(0)
v = orientation.rand(1e5,cs,ss);
w = orientation.rand(10,cs,ss);


[ind,d] = find(v,w,omega)


% compute with distances
d2 = angle(w,v.');

ind2 = sparse(d2 < omega)
d2 = d2(ind2)

[d3,ind3] = mink(d2,K,2) 

end