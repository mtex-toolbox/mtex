%% Spatial Transforms
%
%%
% A spatial transform is a map from position to position, as an object. It
% is what relates two coordinate frames of one physical piece of specimen -
% the distortion between an EBSD map and an SEM image of the same area, the
% drift a stage accumulates during a scan, the foreshortening of a tilted
% surface.
%
% A bare function handle does that much too. A
% <spatialTransform.html |spatialTransform|> also composes,
% inverts, displays itself, fits itself to measured data, and can be stored
% and applied to a second data set - which is what turns a one-off
% correction into something reusable.

plottingConvention.default('y↑→x');
mtexdata twins silent

%% Direction Is the Contract
%
% One rule fixes everything else: |T| maps a position in frame A to the
% position of the same physical point in frame B.
%
% From that follows the order in a product - |T2 * T1| reads in matrix
% order, so |T1| is applied first - and the fact that filling an output grid
% always uses |inv(T)| rather than |T|: for each target pixel you have to
% ask where it came from, not where it goes.
%
% Transforms are two dimensional. They act on x and y and leave z alone.

T = spatialTransformRigid(vector3d(5,-2,0))

%%
% Applying one to positions is |*|, or |eval| written out

pos = ebsd.pos(1,1:3);
posMoved = T * pos;

[pos.x(:), posMoved.x(:)]

%% The Classes
%
% Each class is named for the distortion it models, from the most rigid to
% the most free:
%
% * <spatialTransformId.html |spatialTransformId|> -
% nothing separates the two frames
% * <spatialTransformRigid.html
% |spatialTransformRigid|> - one displacement, the same everywhere
% * <spatialTransformShift.html
% |spatialTransformShift|> - a 2D affine as a homogeneous matrix, i.e.
% translation, rotation, scale and shear together
% * <spatialTransformProjective.html
% |spatialTransformProjective|> - a homography, what a tilted specimen does
% * <spatialTransformPoly.html |spatialTransformPoly|>
% - a displacement varying polynomially across the frame
% * <spatialTransformDrift.html
% |spatialTransformDrift|> - a displacement varying only along the slow scan
% direction, a rolling shutter rather than a smooth field
% * <spatialTransformField.html
% |spatialTransformField|> - no model at all, just where things moved,
% interpolated between the points it was measured at
% * <spatialTransformHandle.html
% |spatialTransformHandle|> - the escape hatch, a function handle
%
% They share a base, so differently modelled hops may sit in one array
% rather than a cell array

[spatialTransformRigid(vector3d(1,0,0)), spatialTransformPoly(zeros(3,2),1)]

%% Fitting One From Two Point Sets
%
% A transform is rarely written down. It is measured: the same features are
% located in both frames, and the class is asked for the member of its
% family that best takes one set onto the other. Every class does this
% through the same static |fit|.
%
% To have something with a known answer, take a projective distortion, push
% the map positions through it, and ask for it back

T0 = spatialTransformProjective([1 0.02 3; -0.01 1.05 -2; 1e-4 2e-4 1]);

posA = ebsd.pos(1:50:end);
posB = T0 * posA;

T = spatialTransformProjective.fit(posA,posB)

%%
% and it is recovered to rounding

max(norm(T*posA - posB))

%%
% Real measurements are not that clean. All fits go through one weighted
% bisquare solver, so a point that disagrees with the rest is outvoted
% rather than dragging the answer - here a tenth of the points are moved
% somewhere else entirely

posBad = posB;
posBad(1:10:end) = posBad(1:10:end) + vector3d(30,-40,0);

TBad = spatialTransformProjective.fit(posA,posBad);

max(norm(TBad*posA - posB))

%%
% Where a confidence per point is available it should be passed as
% |'weights'| instead of being left to the solver to discover. Cross
% correlation returns exactly that - see <xcfShift.html |xcfShift|>.

%% Declaring a Model With + and Composing With *
%
% There are two ways to put transforms together and they are *not* the same
% operation.
%
% |*| composes and simplifies where it can. It decides by value: an operand
% that reports |isid| disappears. An unfitted prototype has zero
% coefficients and so reports exactly that, which makes the product below a
% bare drift with the shift silently gone

spatialTransformShift * spatialTransformDrift

%%
% |+| declares a model. It reads left to right in the order the stages are
% applied and keeps both, dropping only a literal |spatialTransformId| - the
% one class that *means* nothing separates the two frames

spatialTransformShift + spatialTransformDrift

%%
% So |+| writes down a distortion that is about to be fitted, and |*|
% composes ones that already are. Note that |+| chains the maps, it does not
% add the displacements the way |+| on a <vector3d.vector3d.html |vector3d|>
% would.
%
% Either way the order is the same, and both flatten rather than nest

R = spatialTransformRigid(vector3d(1,-2,0));
S = spatialTransformShift([1 0.1 0; 0 1 0; 0 0 1]);

max(norm((R + S)*posA - S*(R*posA)))

%% Inverting
%
% An affine and a homography have exact inverses, and |inv| returns one of
% the same kind

inv(T)

%%
% A polynomial, a spline or a scattered field maps positions perfectly well
% but cannot be solved backwards in closed form. Their inverse is a
% <spatialTransformInverse.html
% |spatialTransformInverse|>, which iterates - and converges as long as the
% displacement field does not fold

P = spatialTransformPoly.fit(posA,posB,'degree',2);

Pinv = inv(P)

%%

max(norm(eval(Pinv,P*posA) - posA))

%%
% A field that does fold has no inverse to find, and the iteration says so
% rather than returning a wrong answer.

%% Collapsing a Chain
%
% A composite evaluates every stage in turn, which is wasted work if it is
% about to be applied to a million pixels many times over.
% <spatialTransform.html |discretize|> samples a chain of any
% length at given positions and returns the single
% <spatialTransformField.html |spatialTransformField|>
% that reproduces it

F = discretize(R + S, posA)

%%

max(norm(F*posA - (R + S)*posA))

%% Applying One to a Map
%
% <EBSD.transform.html |EBSD/transform|> moves every pixel of a map, and the
% unit cell with it, leaving orientations, phase and every other property
% untouched. It takes a |spatialTransform| or a plain function handle

ebsdT = transform(ebsd,S);

plot(ebsd,ebsd.bc,'micronbar','off','layout',[1,2]), mtexColorMap gray
title('as imported')
nextAxis
plot(ebsdT,ebsdT.bc,'micronbar','off'), mtexColorMap gray
title('sheared')

%%
% <grain2d.transform.html |grain2d/transform|> does the same to a grain map,
% by moving its vertices, so a map and the grains reconstructed from it can
% be put through one and the same distortion.
%
% Since the transform inverts, the distortion comes back out again

ebsdBack = transform(ebsdT,inv(S));

max(norm(ebsdBack.pos - ebsd.pos),[],'all')

%% Where the Point Pairs Come From
%
% Nothing above measured anything - |posA| and |posB| were manufactured. In
% practice the pairs come from correlating two pictures of the same area:
% <xcfShift.html |xcfShift|> divides the region they share into tiles, phase
% correlates each against its counterpart, and returns a displacement per
% tile together with the height of the correlation peak that produced it.
% That height is the fit weight, not a diagnostic - a tile that landed on
% featureless background must not get an equal vote:
%
%   [u,peak,pos] = xcfShift(imRef,imTest);
%   T = spatialTransformShift.fit(pos, pos + u, 'weights', peak);
%
% For that to mean anything the two pictures have to agree about where on
% the specimen they sit and about the order they are stored in, which is
% what <EBSDMapsAndImages.html Maps and Images> is about. The whole chain
% run on real data is <example_WCCoSmall_2.html what TrueEBSD does>.

%#ok<*NASGU>
