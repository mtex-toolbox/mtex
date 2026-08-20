function check_axisDistribution
% the angle window of calcAxisDistribution
%
% calcAxisDistribution always integrated the rotation angle over the whole
% fundamental region, so there was no way to ask what an axis angle section
% shows - the axes of those rotations whose angle falls into a given window,
% issue #385. Two implementations have to agree about that window: the
% quadrature in SO3Fun/calcAxisDistribution and the closed form in
% symmetry/calcAxisDistribution, which is the uniform reference.
%
% Every value is computed once here and handed to the checks. A single call
% costs a few tenths of a second almost independently of how many axes it is
% given - the fundamental region and the axis projection dominate - so the
% number of calls, not their size, is what this file has to keep down.
%
% See also
% SO3Fun/calcAxisDistribution symmetry/calcAxisDistribution

cs = crystalSymmetry('mmm');
res = {'resolution',1*degree};
w = 60*degree;

h = vector3d(equispacedS2Grid('resolution',20*degree,'antipodal'));
h = h(:);

odf = 0.4*uniformODF(cs,cs) + 0.6*unimodalODF( ...
  orientation.byEuler(20*degree,30*degree,10*degree,cs,cs),'halfwidth',15*degree);
u = uniformODF(cs,cs);

whole = calcAxisDistribution(odf,h,res{:});
lower = calcAxisDistribution(odf,h,'maxAngle',w,res{:});
upper = calcAxisDistribution(odf,h,'minAngle',w,res{:});

checkFullWindowUnchanged(odf,h,res);
checkAdditive(whole,lower,upper);
checkAgainstClosedForm(u,cs,h,res);
checkEmptyWindow(odf,u,cs,h);

disp('check_axisDistribution: passed');

end

% =========================================================================
function checkFullWindowUnchanged(odf,h,res)
% naming the full window must not change a single value - the default path
% has to stay exactly what it was

implicit = calcAxisDistribution(odf,h,res{:});
explicit = calcAxisDistribution(odf,h,'minAngle',0,'maxAngle',inf,res{:});

assert(isequal(implicit,explicit), ...
  'check_axisDistribution: an explicit full window differs from the default by %.3g',...
  max(abs(implicit(:)-explicit(:))))

end

% -------------------------------------------------------------------------
function checkAdditive(whole,lower,upper)
% two windows that tile the angle range have to add up to the whole one
%
% This is what catches a window clipped at the wrong end, or a weight that
% is not rescaled with the width of the window.

err = max(abs(lower(:)+upper(:)-whole(:))) / max(whole(:));

assert(err < 5e-3, ...
  'check_axisDistribution: the two halves of the angle range miss the whole by %.2g%%',...
  100*err)

% each half has to be a genuine part: everywhere below the whole, nowhere
% the whole, and not identically zero either
tol = 1e-3 * max(whole(:));

assert(all(lower(:) <= whole(:)+tol) && all(upper(:) <= whole(:)+tol), ...
  'check_axisDistribution: a restricted window exceeds the unrestricted one')

assert(any(lower(:) > tol) && max(whole(:)-lower(:)) > tol, ...
  'check_axisDistribution: maxAngle returned all or nothing')
assert(any(upper(:) > tol) && max(whole(:)-upper(:)) > tol, ...
  'check_axisDistribution: minAngle returned all or nothing')

end

% -------------------------------------------------------------------------
function checkAgainstClosedForm(u,cs,h,res)
% for a uniform ODF the quadrature has to reproduce the analytic value, in
% the full range and in a window - that is the only independent check on the
% weights

window = {'minAngle',20*degree,'maxAngle',40*degree};

check(calcAxisDistribution(u,h,res{:}), ...
  calcAxisDistribution(cs,cs,h),'the full range');

check(calcAxisDistribution(u,h,window{:},res{:}), ...
  calcAxisDistribution(cs,cs,h,window{:}),'a 20 to 40 degree window');

function check(numeric,closed,what)

  err = max(abs(numeric(:)-closed(:))) / max(closed(:));

  % the rectangle rule converges only linearly in the step and a narrow
  % window gets few points, so a percent or two is the quadrature and not a
  % defect. Everything this test exists to catch - the wrong end clipped, a
  % weight scaled by the region instead of by the window - is off by tens of
  % percent or more
  assert(err < 3e-2, ...
    'check_axisDistribution: %s differs from the closed form by %.2g%%',...
    what,100*err)

end

end

% -------------------------------------------------------------------------
function checkEmptyWindow(odf,u,cs,h)
% a window whose ends are the wrong way round is empty - not negative, and
% not the whole range. Both implementations have to agree on that

window = {'minAngle',40*degree,'maxAngle',20*degree};

empty = {calcAxisDistribution(odf,h,window{:}), ...
  calcAxisDistribution(u,h,window{:}), ...
  calcAxisDistribution(cs,cs,h,window{:})};

for k = 1:numel(empty)
  assert(all(abs(empty{k}(:)) < 1e-10), ...
    'check_axisDistribution: an empty angle window returned up to %.3g',...
    max(abs(empty{k}(:))))
end

end
