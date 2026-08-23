function check_spatialTransformFit(varargin)
% test that every fitted spatial transform recovers a known distortion
%
% One pattern throughout: build a transform, push a point cloud through it,
% hand the two clouds back to fit, and require the coefficients or the
% mapped positions to come back. Where a class is robust, the same case is
% run again with a corrupted measurement that must be outvoted.
%
% Syntax
%   check_spatialTransformFit
%
% See also
% spatialTransform check_spatialTransform

checkRigid
checkPoly
checkProjective
checkDrift
checkField
checkRobustness
checkGenericInverse
checkDiscretize
checkTiltStages

end

% =========================================================================
function pos = cloud(n)
% a point cloud on a frame that is wider than it is tall, as a map is
pos = vector3d(200*rand(n,1), 150*rand(n,1), zeros(n,1));
end

% =========================================================================
function checkRigid
% the whole frame moved by one displacement

u = vector3d(3.5,-2.25,0);
posA = cloud(50);
posB = spatialTransformRigid(u) * posA;

T = spatialTransformRigid.fit(posA,posB);
assert(norm(T.u - u) < 1e-12,'rigid fit off by %g',norm(T.u - u))

% the weights are the point of it - one wild measurement, zero weighted
posB.x(1) = posB.x(1) + 500;
w = ones(50,1); w(1) = 0;
Tw = spatialTransformRigid.fit(posA,posB,'weights',w);
assert(norm(Tw.u - u) < 1e-12,'a zero weighted outlier moved the rigid fit by %g',...
  norm(Tw.u - u))

% a negative correlation peak is no evidence, not evidence against
Tn = spatialTransformRigid.fit(posA,posB,'weights',[-1; ones(49,1)]);
assert(norm(Tn.u - u) < 1e-12,'a negative weight was not clamped to zero')

end

% =========================================================================
function checkPoly
% a polynomial displacement, at both degrees

posA = cloud(200);

for degree = [1 2]

  m = 3 + 3*(degree-1);
  c = 0.01*randn(m,2); c(1,:) = [2 -1];

  posB = spatialTransformPoly(c,degree) * posA;

  T = spatialTransformPoly.fit(posA,posB,'degree',degree);
  assert(norm(T.c - c,'fro') < 1e-9,...
    'degree %d fit off by %g',degree,norm(T.c - c,'fro'))

end

% degree 1 is an affine, and says so exactly
c = [2 -1; 0.03 0.002; -0.004 0.02];
T = spatialTransformPoly(c,1);
S = shiftMatrix(T);
assert(max(norm(S*posA - T*posA)) < 1e-12,...
  'the affine form of a degree 1 polynomial evaluates differently')

% and inverting it goes through that exact form, not an iteration
assert(isa(inv(T),'spatialTransformShift'),...
  'inv of a degree 1 polynomial is a %s, expected an exact affine',class(inv(T)))

end

% =========================================================================
function checkProjective
% a homography, including the perspective division

H = [1.01 0.02 3; -0.015 0.99 -2; 2e-4 -1.5e-4 1];
T = spatialTransformProjective(H);

posA = cloud(200);
posB = T * posA;

% the perspective division is what makes this projective, so check it is
% there - an affine reading of the same matrix would differ measurably
affine = spatialTransformShift([H(1,:); H(2,:); 0 0 1]) * posA;
assert(max(norm(affine - posB)) > 1,...
  'the test homography has too little perspective to detect the division')

Tfit = spatialTransformProjective.fit(posA,posB);
assert(norm(Tfit.H - H,'fro') < 1e-9,...
  'homography fit off by %g',norm(Tfit.H - H,'fro'))

% its inverse is exact, not an iteration
assert(isa(inv(T),'spatialTransformProjective'),...
  'inv of a homography is a %s',class(inv(T)))
assert(max(norm(inv(T)*(T*posA) - posA)) < 1e-9,'homography round trip lost points') %#ok<MINV>

end

% =========================================================================
function checkDrift
% a linear spline down the slow scan direction

rows = (0:20).'*7;
u = [0.3*rows/10, -0.2*sqrt(rows)];
T = spatialTransformDrift(rows,u);

% a point cloud laid out in scan lines, several points per line
[X,Y] = meshgrid(linspace(5,195,12),rows);
posA = vector3d(X(:),Y(:),zeros(numel(X),1));
posB = T * posA;

Tfit = spatialTransformDrift.fit(posA,posB);
assert(numel(Tfit.s) == numel(rows),...
  'drift fit found %d knots, expected %d',numel(Tfit.s),numel(rows))
assert(norm(Tfit.u - u,'fro') < 1e-10,...
  'drift fit off by %g',norm(Tfit.u - u,'fro'))

% every point on a line moves together, whatever its fast coordinate
moved = T * vector3d([10; 190],[rows(5); rows(5)],[0;0]);
assert(abs(diff(moved.x) - 180) < 1e-12,...
  'two points on one scan line were displaced differently')

% outside the measured band there is no answer, deliberately
outside = T * vector3d(100,rows(end)+50,0);
assert(isnan(outside.x),'drift extrapolated where it has no knots')

% unless asked
Te = spatialTransformDrift(rows,u,'extrapolate');
beyond = Te * vector3d(100,rows(end)+50,0);
assert(~isnan(beyond.x),'''extrapolate'' did not extrapolate')

% the median is what makes a bad line survivable
posB.x(1) = posB.x(1) + 1000;
Tm = spatialTransformDrift.fit(posA,posB);
assert(norm(Tm.u - u,'fro') < 1e-10,...
  'one wild point in a scan line moved the median by %g',norm(Tm.u - u,'fro'))

end

% =========================================================================
function checkField
% a scattered field interpolates its own samples exactly

posA = cloud(300);
u = vector3d(0.5*sin(posA.x/40), 0.5*cos(posA.y/30), zeros(300,1));

T = spatialTransformField(posA,u);
moved = T * posA;

assert(max(norm(moved - (posA + u))) < 1e-9,...
  'a field did not reproduce its own samples')

% fit is the same thing from two clouds
Tfit = spatialTransformField.fit(posA,posA + u);
assert(max(norm(Tfit*posA - (posA + u))) < 1e-9,'field fit lost its samples')

% and it is usable away from them
mid = spatialTransformField(posA,u) * cloud(20);
assert(all(isfinite(mid.x)),'a field returned non finite positions inside its hull')

end

% =========================================================================
function checkRobustness
% the robust solver has to beat a plain one on contaminated data

posA = cloud(200);
c = [2 -1; 0.03 0.002; -0.004 0.02];
posB = spatialTransformPoly(c,1) * posA;

% a tenth of the measurements are nonsense
bad = 1:20;
posB.x(bad) = posB.x(bad) + 80*randn(numel(bad),1);
posB.y(bad) = posB.y(bad) - 60;

Trob = spatialTransformPoly.fit(posA,posB,'degree',1);
Tols = spatialTransformPoly.fit(posA,posB,'degree',1,'noRobust');

eRob = norm(Trob.c - c,'fro');
eOls = norm(Tols.c - c,'fro');

assert(eRob < eOls/3,...
  'bisquare did not outperform plain least squares on 10%% contamination: %g vs %g',...
  eRob,eOls)

end

% =========================================================================
function checkGenericInverse
% classes with no closed form inverse iterate, and refuse when they cannot

posA = cloud(100);

% a gentle quadratic inverts fine
c = zeros(6,2); c(1,:) = [1 -2]; c(4,1) = 1e-5; c(6,2) = -1.5e-5;
T = spatialTransformPoly(c,2);

Ti = inv(T);
assert(isa(Ti,'spatialTransformInverse'),'expected an iterated inverse, got %s',class(Ti))
assert(max(norm(Ti*(T*posA) - posA)) < 1e-6,'the iterated inverse did not return the points') %#ok<MINV>

% inverting it again is free, not another wrapper
assert(isa(inv(Ti),'spatialTransformPoly'),'inv of an inverse did not unwrap')

% a field that folds has no inverse to find, and says so
fold = spatialTransformPoly([0 0; -2 0; 0 0],1);
try
  eval(spatialTransformInverse(fold,'iterMax',20),cloud(10));
  error('a folding field was inverted')
catch e
  assert(strcmp(e.identifier,'MTEX:spatialTransform:notInvertible'),...
    'wrong identifier for a folding field: %s',e.identifier)
end

end

% =========================================================================
function checkDiscretize
% any chain collapses to one field, agreeing where it was sampled

posA = cloud(400);

T = spatialTransformPoly([1 -2; 0.02 0.001; -0.001 0.015],1) * ...
    spatialTransformRigid(vector3d(5,3,0));

F = discretize(T,posA);
assert(isa(F,'spatialTransformField'),'discretize returned a %s',class(F))
assert(max(norm(F*posA - T*posA)) < 1e-9,...
  'the discretized field disagrees with the chain at its own samples')

% norm reports how far the chain moves things
n = norm(T,posA);
assert(numel(n) == 400 && all(n > 0),'norm(T,pos) did not report a distance per point')

end

% =========================================================================
function checkTiltStages
% a tilt is fitted stage by stage against a re-measured residual

posA = cloud(300);

H = [1.01 0.02 3; -0.015 0.99 -2; 2e-4 -1.5e-4 1];
curve = zeros(6,2); curve(4,1) = 2e-5; curve(6,2) = -3e-5; curve(1,:) = [0.4 -0.3];

truth = spatialTransformPoly(curve,2) * spatialTransformProjective(H);
posB = truth * posA;

T = spatialTransformTilt;
assert(length(T.stages) == 3,'a tilt has %d stages, expected 3',length(T.stages))

% an unfitted tilt is the identity, so the loop below can start anywhere
assert(isid(T),'an unfitted tilt is not the identity')

% the loop the caller drives - here the residual is exact rather than
% re-correlated, which is what makes this testable without any images
before = max(norm(posB - posA));
resid = nan(1,length(T.stages));

for s = 1:length(T.stages)
  T = fitStage(T,s,T*posA,posB);
  resid(s) = max(norm(T*posA - posB));
end

% no stage may undo the one before it
assert(all(diff([before resid]) <= 1e-12),...
  'a stage made the residual worse: %s',mat2str([before resid],4))

% the three together have to account for essentially all of it. They cannot
% account for ALL of it and it is worth knowing why: after stage 1 the
% residual is a quadratic in the TRUE projective image, but it is measured
% against the FITTED one, and a quadratic composed with a projective is
% rational rather than polynomial. The leftover is that cross term.
assert(resid(end) < before/1000,...
  'a staged tilt fit only got from %g to %g',before,resid(end))

% where the truth is inside the model there is no such term, and the fit
% is exact - which is what tells us the leftover above is the model and
% not the machinery
posP = spatialTransformProjective(H) * posA;
Tp = spatialTransformTilt;
for s = 1:length(Tp.stages), Tp = fitStage(Tp,s,Tp*posA,posP); end

assert(max(norm(Tp*posA - posP)) < 1e-9,...
  'a purely projective distortion was not recovered exactly: %g',...
  max(norm(Tp*posA - posP)))

end
