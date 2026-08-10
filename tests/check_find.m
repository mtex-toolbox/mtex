function check_find
% cross-check @orientation/find against brute force angle(w,v.')
%
% The two symmetry branch of @orientation/find used to
%
%  (a) re-index with the wrong modulus when numSym(CS) < numSym(SS) - v*cs
%      has layout N x numSym(cs), so the original index is mod(ind-1,N)+1,
%      not mod(ind-1,numSym(cs))+1
%  (b) apply the k-nearest re-indexing to the sparse incidence matrix of the
%      epsilon mode - leaving it uncollapsed in one branch and densifying it
%      into garbage in the other
%  (c) never re-index the distances d
%  (d) return k symmetric copies of the SAME orientation as the k nearest
%  (e) reject equal but independently constructed symmetries, since == on a
%      crystalSymmetry is handle identity
%
% The single symmetry path returned the incidence matrix with width max(id)
% instead of numel(v), as a sparse double of counts instead of a logical,
% and with the distances of duplicate columns summed instead of minimised.

rng(0)
tol = 1e-9;

N = 300;  M = 10;

% cs, ss, label - the last column names the fold branch that is exercised
cases = { ...
  crystalSymmetry('1')  , specimenSymmetry('1')  , 'triv x triv', 'none'  ; ...
  crystalSymmetry('321'), specimenSymmetry('1')  , '321 x triv' , 'none'  ; ...
  crystalSymmetry('1')  , specimenSymmetry('mmm'), 'triv x mmm' , 'none'  ; ...
  crystalSymmetry('432'), specimenSymmetry('mmm'), '432 x mmm'  , 'foldSS'; ...
  crystalSymmetry('321'), specimenSymmetry('mmm'), '321 x mmm'  , 'foldSS'; ...
  crystalSymmetry('2')  , specimenSymmetry('mmm'), '2 x mmm'    , 'foldCS'};

for i = 1:size(cases,1)

  cs = cases{i,1};  ss = cases{i,2};  lbl = cases{i,3};

  v = orientation.rand(N,cs,ss);
  w = orientation.rand(M,cs,ss);

  dRef = angle(w,v.');
  assert(isequal(size(dRef),[M N]),...
    '%s: the brute force reference has the wrong shape',lbl)

  checkK(v,w,dRef,1,lbl,tol);
  checkK(v,w,dRef,3,lbl,tol);
  checkK(v,w,dRef,7,lbl,tol);
  checkClosest(v,w,dRef,lbl,tol);
  checkEps(v,w,dRef,10*degree,lbl,tol);
  checkEps(v,w,dRef,25*degree,lbl,tol);

end

% --- equal but independently constructed symmetry handles ----------------
cs = crystalSymmetry('321');  ss = specimenSymmetry('mmm');
v = orientation.rand(N,cs,ss);
w = orientation(orientation.rand(M,cs,ss),crystalSymmetry('321'),specimenSymmetry('mmm'));

assert(v.CS ~= w.CS,'this check needs two DISTINCT crystal symmetry handles')
assert(eqTol(v.CS,w.CS),'the two crystal symmetry handles must be eqTol equal')

[ind,d] = find(v,w,3);
checkKResult(ind,d,angle(w,v.'),3,'distinct handles',tol)

% --- a genuine mismatch must still be rejected ---------------------------
u = orientation.rand(M,crystalSymmetry('432'),ss);
failed = false;
try %#ok<TRYNC>
  find(v,u,3);
  failed = true;
end
assert(~failed,'find must reject orientations with different crystal symmetries')

% --- misorientations, i.e. SS is a crystalSymmetry -----------------------
cs = crystalSymmetry('321');
v = orientation.rand(N,cs,cs);
w = orientation.rand(M,cs,cs);
dRef = angle(w,v.');
checkK(v,w,dRef,3,'misorientation 321',tol);
checkEps(v,w,dRef,15*degree,'misorientation 321',tol);

% --- antipodal misorientations -------------------------------------------
% Note: angle() ignores the antipodal flag, so it cannot serve as the
% reference here - build the antipodal distance min(d(w,v),d(w,inv(v)))
% explicitly instead.
v.antipodal = true;
w.antipodal = true;
vi = inv(v); vi.CS = v.CS; vi.SS = v.SS; vi.antipodal = false;
v0 = v; v0.antipodal = false;
w0 = w; w0.antipodal = false;
dRef = min(angle(w0,v0.'),angle(w0,vi.'));
checkK(v,w,dRef,3,'antipodal 321',tol);
checkEps(v,w,dRef,15*degree,'antipodal 321',tol);

% --- exact hits: d == 0 must survive the sparse round trip ---------------
cs = crystalSymmetry('321');  ss = specimenSymmetry('mmm');
v = orientation.rand(N,cs,ss);
w = v.subSet(1:5);
[ind,d] = find(v,w,5*degree);
for j = 1:5
  assert(ind(j,j),'the exact hit %d is missing from the incidence matrix',j)
  % 2*acos(dot) is only accurate to about sqrt(eps) next to dot == 1
  assert(abs(d(j,j)) < 1e-6,'the exact hit %d has a non zero distance',j)
end

% --- w given as a plain rotation, see find.m:34-36 -----------------------
w = orientation.rand(M,cs,ss);
[ind,d] = find(v,rotation(w),3);
checkKResult(ind,d,angle(w,v.'),3,'w as a rotation',tol)

% --- the real caller: volume needs a LOGICAL matrix of width numel(v) ----
w = orientation.rand(1,cs,ss);
ind = find(v,w,20*degree);
assert(islogical(ind),'the epsilon mode must return a sparse LOGICAL matrix')
assert(isequal(size(ind),[1 N]),...
  'the epsilon mode must return a numel(w) x numel(v) matrix')
volume(v,w,20*degree,'weights',ones(1,N)/N);

disp('check_find passed')

end

% -------------------------------------------------------------------------
function checkK(v,w,dRef,k,lbl,tol)

[ind,d] = find(v,w,k);
checkKResult(ind,d,dRef,k,lbl,tol)

end

% -------------------------------------------------------------------------
function checkKResult(ind,d,dRef,k,lbl,tol)

[M,N] = size(dRef);

assert(isequal(size(ind),[M k]),'%s, k=%d: ind must be %d x %d',lbl,k,M,k)
assert(isequal(size(d),[M k]),'%s, k=%d: d must be %d x %d',lbl,k,M,k)
assert(all(ind(:) >= 1 & ind(:) <= N),...
  '%s, k=%d: the returned index is out of range',lbl,k)

% the k nearest points out of v, not k symmetric copies of the same point
for j = 1:M
  assert(numel(unique(ind(j,:))) == k,...
    '%s, k=%d: row %d contains duplicated indices',lbl,k,j)
end

% d must be the k smallest reference distances - unambiguous even under ties
dSort = sort(dRef,2);
assert(max(abs(double(d) - dSort(:,1:k)),[],'all') < tol,...
  '%s, k=%d: the reported distances are not the k smallest',lbl,k)

% ind and d must describe the same points
lin = sub2ind([M N],repmat((1:M).',1,k),double(ind));
assert(max(abs(dRef(lin) - double(d)),[],'all') < tol,...
  '%s, k=%d: ind and d disagree',lbl,k)

end

% -------------------------------------------------------------------------
function checkClosest(v,w,dRef,lbl,tol)

[ind,d] = find(v,w);
M = size(dRef,1);

assert(isequal(size(ind),[M 1]),...
  '%s: the two argument syntax must return a numel(w) x 1 index',lbl)
assert(max(abs(double(d(:)) - min(dRef,[],2))) < tol,...
  '%s: the two argument syntax did not return the closest point',lbl)

lin = sub2ind(size(dRef),(1:M).',double(ind(:)));
assert(max(abs(dRef(lin) - double(d(:)))) < tol,...
  '%s: the two argument syntax has ind and d disagreeing',lbl)

end

% -------------------------------------------------------------------------
function checkEps(v,w,dRef,epsilon,lbl,tol)

[M,N] = size(dRef);
[ind,d] = find(v,w,epsilon);

assert(isequal(size(ind),[M N]),...
  '%s, eps: ind must be numel(w) x numel(v)',lbl)
assert(isequal(size(d),[M N]),'%s, eps: d must be numel(w) x numel(v)',lbl)
assert(issparse(ind) && issparse(d),'%s, eps: both outputs must be sparse',lbl)
assert(islogical(ind),'%s, eps: ind must be a sparse LOGICAL matrix',lbl)

% stay away from the boundary, the search uses a strict comparison
band = 1e-6;
mustHave = dRef < epsilon - band;
mustNot  = dRef > epsilon + band;
assert(all(ind(mustHave)),'%s, eps: a point inside the radius is missing',lbl)
assert(~any(ind(mustNot)),'%s, eps: a point outside the radius was reported',lbl)

% d must carry the MINIMUM distance - summing duplicates would be larger
I = logical(ind);
assert(max(abs(full(d(I)) - dRef(I))) < tol,...
  '%s, eps: the distances are wrong - summed instead of minimised?',lbl)
assert(nnz(d) <= nnz(ind),'%s, eps: d must be 0 wherever ind is 0',lbl)

end
