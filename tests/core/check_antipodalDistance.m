function check_antipodalDistance
% check that orientation/angle, dot and dot_outer honour the antipodal flag
%
% For misorientations the antipodal flag means grain exchange symmetry: a
% misorientation and its inverse describe the same boundary, so the distance
% between two of them is min(d(w,v),d(w,inv(v))).
%
% angle and dot ignored the flag completely - they returned the plain
% misorientation angle, up to 13 degree too large on a '321' sample. dot_outer
% honoured it only by accident: it reaches the inversion through symmetrise,
% which sees the flag only on the operand that happens to be symmetrised, and
% which one that is depends on the two input lengths. So dot_outer(v,w) and
% dot_outer(w,v).' disagreed.
%
% symmetrise, project2FundamentalRegion and find have always honoured the
% flag, hence the ground truth used below: the minimum over all symmetric
% equivalents of v together with their inverses.

checkAgainstBruteForce;
checkOrderIndependence;
checkFlagOnEitherOperand;
checkUnflaggedUnchanged;
checkShapes;

disp('check_antipodalDistance: passed');

end

% =========================================================================
function checkAgainstBruteForce
% angle, dot and dot_outer must all reproduce the explicit minimum

tol = 1e-8*degree;

for cs = symmetries

  [v,w] = samples(cs{1});
  bf = bruteForce(v,w);

  err(angle(w,v.'), bf, tol, cs{1}, 'angle');
  err(2*real(acos(min(1,abs(dot(w,v.'))))), bf, tol, cs{1}, 'dot');
  err(2*real(acos(min(1,abs(dot_outer(w,v))))), bf, tol, cs{1}, 'dot_outer');

end

end

% -------------------------------------------------------------------------
function checkOrderIndependence
% dot_outer(v,w) and dot_outer(w,v).' must agree - they did not, the answer
% depended on which operand was the shorter one

tol = 1e-8*degree;

for cs = symmetries

  [v,w] = samples(cs{1});          % 6 and 4 elements, i.e. both orders occur
  bf = bruteForce(v,w);

  err(2*real(acos(min(1,abs(dot_outer(v,w))))).', bf, tol, cs{1}, ...
    'dot_outer with the flagged operand second');
  err(angle(v,w.').', bf, tol, cs{1}, 'angle with swapped arguments');

end

end

% -------------------------------------------------------------------------
function checkFlagOnEitherOperand
% the flag on one operand is enough, and it does not matter which

tol = 1e-8*degree;

for cs = symmetries

  [v,w] = samples(cs{1});
  ref = angle(w,v.');

  v0 = v; v0.antipodal = false;
  w0 = w; w0.antipodal = false;

  err(angle(w0,v.'), ref, tol, cs{1}, 'flag on the second operand only');
  err(angle(w,v0.'), ref, tol, cs{1}, 'flag on the first operand only');

end

end

% -------------------------------------------------------------------------
function checkUnflaggedUnchanged
% without the flag nothing may change - the plain misorientation angle stays

tol = 1e-8*degree;

for cs = symmetries

  [v,w] = samples(cs{1});
  v.antipodal = false; w.antipodal = false;

  bf = zeros(length(w),length(v));
  for i = 1:length(w)
    for j = 1:length(v)
      s = symmetrise(v.subSet(j));
      bf(i,j) = min(angle(rotation(w.subSet(i)),rotation(s),'noSymmetry'));
    end
  end

  err(angle(w,v.'), bf, tol, cs{1}, 'angle without the flag');
  err(2*real(acos(min(1,abs(dot_outer(w,v))))), bf, tol, cs{1}, ...
    'dot_outer without the flag');

end

end

% -------------------------------------------------------------------------
function checkShapes
% the flag must not change the size of the result, and the single argument
% syntax stays untouched since angle(o) == angle(inv(o)) anyway

cs = crystalSymmetry('321');
[v,w] = samples(cs);

assert(isequal(size(angle(w,v.')),[length(w) length(v)]),...
  'check_antipodalDistance: angle changed its output size')
assert(isequal(size(dot_outer(w,v)),[length(w) length(v)]),...
  'check_antipodalDistance: dot_outer changed its output size')
assert(isequal(size(angle(v,w.subSet(1))),size(v)),...
  'check_antipodalDistance: angle against a scalar changed its output size')

vi = inv(v); vi.CS = v.CS; vi.SS = v.SS;
assert(max(abs(angle(v) - angle(vi))) < 1e-8*degree,...
  'check_antipodalDistance: the single argument angle is not inversion invariant')

% a query against itself has to be zero
assert(max(diag(angle(v,v.'))) < 1e-4*degree,...
  'check_antipodalDistance: the distance of a misorientation to itself is not zero')

% dot_outer(...,'all') keeps every equivalent, the inverted ones included
d = dot_outer(v,v,'all');
assert(size(d,3) == 2*numSym(cs)^2,...
  'check_antipodalDistance: dot_outer(...,''all'') dropped the inverted equivalents')

end

% =========================================================================
function cs = symmetries

cs = {crystalSymmetry('321'), crystalSymmetry('m-3m'), ...
  crystalSymmetry('1'), crystalSymmetry('622')};

end

% -------------------------------------------------------------------------
function [v,w] = samples(cs)
% two sets of misorientations of different length, both flagged

rng(0)
v = orientation.rand(6,cs,cs); v.antipodal = true;
w = orientation.rand(4,cs,cs); w.antipodal = true;

end

% -------------------------------------------------------------------------
function d = bruteForce(v,w)
% the smallest angle to any symmetric equivalent of v or of its inverse

d = zeros(length(w),length(v));
for i = 1:length(w)
  for j = 1:length(v)
    s = symmetrise(v.subSet(j));   % already includes the inverses
    d(i,j) = min(angle(rotation(w.subSet(i)),rotation(s),'noSymmetry'));
  end
end

end

% -------------------------------------------------------------------------
function err(d,ref,tol,cs,what)

e = max(abs(d(:)-ref(:)));
assert(e < tol, 'check_antipodalDistance: %s is off by %.3f degree for %s',...
  what, e/degree, cs.pointGroup)

end
