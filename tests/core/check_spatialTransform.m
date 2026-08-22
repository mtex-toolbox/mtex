function check_spatialTransform(varargin)
% test the spatial transform algebra - compose, invert, evaluate, fit
%
% Direction is the contract everything else rests on: T maps a position in
% frame A to the same point in frame B, and T2*T1 applies T1 first. Most
% cases below are really assertions about that order.
%
% Syntax
%   check_spatialTransform
%
% See also
% spatialTransform spatialTransformShift EBSD/transform

checkIdentity
checkEvalAndOrder
checkInverse
checkAbsorb
checkComposite
checkHeterogeneous
checkFit
checkFitWeights
checkErrors

end

%% the identity does nothing and disappears from a product
function checkIdentity

id = spatialTransformId;
pos = vector3d(randn(20,1),randn(20,1),zeros(20,1));

assert(isid(id),'the identity is not id')
assert(max(norm(eval(id,pos) - pos)) == 0,'the identity moved a position')

T = spatialTransformShift([1 0.2 3; -0.1 1 -2; 0 0 1]);

assert(isa(id*T,'spatialTransformShift'),'identity did not vanish on the left')
assert(isa(T*id,'spatialTransformShift'),'identity did not vanish on the right')

end

%% T*pos evaluates, and T2*T1 applies T1 first
function checkEvalAndOrder

pos = vector3d(randn(50,1),randn(50,1),zeros(50,1));

% a pure translation and a pure scaling, which do not commute
Tt = spatialTransformShift([1 0 10; 0 1 0; 0 0 1]);
Ts = spatialTransformShift([2 0 0; 0 2 0; 0 0 1]);

assert(max(norm(Tt*pos - eval(Tt,pos))) < 1e-12,'T*pos disagrees with eval')

% scale after translate: (x+10)*2
lhs = (Ts*Tt) * pos;
rhs = Ts * (Tt * pos);
assert(max(norm(lhs - rhs)) < 1e-12,'composition is not right associative')
assert(max(abs(lhs.x - 2*(pos.x+10))) < 1e-12,'T2*T1 did not apply T1 first')

% and the other order differs, so the test above has teeth
other = (Tt*Ts) * pos;
assert(max(abs(other.x - (2*pos.x+10))) < 1e-12,'T1*T2 order wrong')

% z is untouched
scaled = Ts * pos;
assert(max(abs(scaled.z - pos.z)) == 0,'a 2D transform moved z')

end

%% compose then invert is the identity
function checkInverse

pos = vector3d(randn(100,1),randn(100,1),zeros(100,1));

T = spatialTransformShift([1.03 0.11 4.2; -0.07 0.98 -1.5; 0 0 1]);

assert(max(norm(inv(T)*(T*pos) - pos)) < 1e-12,'affine round trip lost points') %#ok<MINV>
assert(isid(T*inv(T)),'T*inv(T) is not the identity') %#ok<MINV>

% a composite inverts by chaining its stages in reverse
C = T * spatialTransformShift([2 0 1; 0 0.5 -3; 0 0 1]);
assert(max(norm(inv(C)*(C*pos) - pos)) < 1e-12,'composite round trip lost points') %#ok<MINV>

% a handle inverts only when it was given an inverse
h = spatialTransformHandle(@(p) p + vector3d(1,2,0), @(p) p - vector3d(1,2,0));
assert(max(norm(inv(h)*(h*pos) - pos)) < 1e-12,'handle round trip lost points') %#ok<MINV>

end

%% two affines make a third, mixed types make a composite
function checkAbsorb

T1 = spatialTransformShift([1 0 3; 0 1 0; 0 0 1]);
T2 = spatialTransformShift([2 0 0; 0 2 0; 0 0 1]);

assert(isa(T1*T2,'spatialTransformShift'),'two affines did not absorb')

h = spatialTransformHandle(@(p) p);
assert(isa(T1*h,'spatialTransformComposite'),'mixed types did not compose')

end

%% a composite flattens and keeps its stages in application order
function checkComposite

T1 = spatialTransformShift([1 0 3; 0 1 0; 0 0 1]);
h1 = spatialTransformHandle(@(p) p + vector3d(0,1,0));
h2 = spatialTransformHandle(@(p) 2*p);

C = h2 * (h1 * T1);

assert(isa(C,'spatialTransformComposite'),'not a composite')
assert(length(C.stages) == 3,'composite nested instead of flattening, %d stages',...
  length(C.stages))
assert(isa(C.stages(1),'spatialTransformShift'),'stages are not in application order')

pos = vector3d(randn(10,1),randn(10,1),zeros(10,1));
assert(max(norm(C*pos - h2*(h1*(T1*pos)))) < 1e-12,'composite evaluated out of order')

end

%% differently modelled transforms live in one array
function checkHeterogeneous

T = [spatialTransformId, ...
     spatialTransformShift([1 0 5; 0 1 0; 0 0 1]), ...
     spatialTransformHandle(@(p) 2*p)];

assert(isa(T,'spatialTransform'),'the array is not a spatialTransform')
assert(length(T) == 3,'the array lost an element')

pos = vector3d(1,1,0);
moved = T(2) * pos;
assert(abs(moved.x - 6) < 1e-12,'indexing a mixed array gave the wrong element')

end

%% fit recovers a known affine
function checkFit

M = [1.02 0.13 4; -0.09 0.97 -2.5; 0 0 1];
T = spatialTransformShift(M);

posA = vector3d(randn(200,1),randn(200,1),zeros(200,1));
posB = T * posA;

Tfit = spatialTransformShift.fit(posA,posB);
assert(norm(Tfit.M - M,'fro') < 1e-10,'fit did not recover a clean affine')

% with noise the fit is close, and unbiased enough to beat the noise level
posN = posB + vector3d(0.01*randn(200,1),0.01*randn(200,1),zeros(200,1));
Tn = spatialTransformShift.fit(posA,posN);
assert(norm(Tn.M - M,'fro') < 0.01,'fit was pulled too far by noise')

end

%% weights let a bad point be outvoted
function checkFitWeights

M = [1 0 5; 0 1 -3; 0 0 1];
posA = vector3d(randn(60,1),randn(60,1),zeros(60,1));
posB = spatialTransformShift(M) * posA;

% one point moved a long way, which unweighted drags the fit
posB.x(1) = posB.x(1) + 50;

Tbad = spatialTransformShift.fit(posA,posB);
assert(norm(Tbad.M - M,'fro') > 0.1,'the outlier did not move the unweighted fit')

w = ones(60,1); w(1) = 0;
Tgood = spatialTransformShift.fit(posA,posB,'weights',w);
assert(norm(Tgood.M - M,'fro') < 1e-10,'a zero weighted outlier still moved the fit')

end

%% the errors say what to do about them
function checkErrors

pos = vector3d(randn(5,1),randn(5,1),zeros(5,1));

try
  spatialTransformShift([1 0 0; 0 1 0; 0.1 0 1]);
  error('a projective matrix was accepted as affine')
catch e
  assert(strcmp(e.identifier,'MTEX:spatialTransform:notAffine'),...
    'wrong identifier for a projective matrix: %s',e.identifier)
end

try
  inv(spatialTransformHandle(@(p) p));
  error('a handle with no inverse was inverted')
catch e
  assert(strcmp(e.identifier,'MTEX:spatialTransform:noInverse'),...
    'wrong identifier for a missing inverse: %s',e.identifier)
end

try
  spatialTransformShift.fit(pos(1:2),pos(1:2));
  error('an affine was fitted to two points')
catch e
  assert(strcmp(e.identifier,'MTEX:spatialTransform:tooFewPoints'),...
    'wrong identifier for too few points: %s',e.identifier)
end

end
