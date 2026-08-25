%% Fibres
%
%%
% A <fibre.fibre.html |@fibre|> is to rotation space what a straight line is
% to Euclidean space: the shortest path between two rotations, and the set
% traced out by continuing along it. Fibres matter because many common
% textures are concentrated around such curves: all orientations that put
% one crystal direction along one specimen direction, with the rotation
% about that direction left free.

plottingConvention.default('y↑→x');

% consider cubic symmetry
cs = crystalSymmetry('432');

% two random orientations
oriA = orientation.rand(cs)

%%

oriB = orientation.rand(cs)

%%
% Under crystal symmetry an orientation stands for a whole set of
% equivalent ones, so "the path between A and B" is only well defined once
% the equivalent of |oriB| closest to |oriA| has been picked out.

oriB = oriB.project2FundamentalRegion(oriA)

%%
% The connecting fibre is then

f = fibre(oriA,oriB)

plot(oriA,'axisAngle','filled','MarkerSize',20)
hold on
plot(oriB,'axisAngle','filled','MarkerSize',20)
plot(f,'lineWidth',3,'lineColor','red')
hold off
axis off

%% A Fibre is a Circle
%
% Rotation space is curved. In the unit-quaternion representation a fibre is
% a great circle on the 3-sphere (with antipodal quaternions identified as
% the same rotation), rather than a straight Euclidean line. Continued past
% its two endpoints it closes up, which the option |'full'| requests.

f = fibre(oriA,oriB,'full')

hold on
plot(f,'lineWidth',3,'lineColor','red')
hold off

%%
% The result looks like several disconnected arcs, but it is one circle: the
% plot shows the fundamental region only, and the circle leaves it and
% re-enters as a symmetrically equivalent piece. Drawn in the complete
% rotation space, without folding anything back, it is a single closed
% curve.

plot(oriA,'axisAngle','filled','MarkerSize',20,'complete')
hold on
plot(oriB,'axisAngle','filled','MarkerSize',20)
plot(f,'axisAngle','lineWidth',3,'lineColor','red')
hold off
axis off

%% The Two Directions Behind a Fibre
%
% The other way to describe the same set: a fibre is all rotations that take
% one crystal direction |h| onto one specimen direction |r|. Both are stored
% on the fibre and read back as properties.

f.h

%%

f.r

%%
% These are the axis of the relative rotation, written once in specimen
% coordinates and once in crystal coordinates. They satisfy
% |oriA * h = oriB * h = r|: the endpoint orientations send the same crystal
% direction onto the same specimen direction.

r = axis(oriB,oriA)

%%

h = inv(oriA) * axis(oriB,oriA)

%%
% Given the pair, the fibre is defined directly, without reference to the
% two orientations it happened to come from.

f = fibre(h,r)

%% Sampling a Fibre
%
% <fibre.orientation.html |orientation|> discretises a fibre into a list of
% orientations, which is what a plot or a calculation along the fibre needs.
% Specify the number of samples explicitly when it matters.

ori = orientation(f,'points',100);

length(ori)

%%

figure
plot(ori,'axisAngle')

%% Next
%
% Fibres of the standard texture components, and the fibre ODFs built on
% them, are <OrientationFibre.html Fibres of Orientations> and
% <FibreODFs.html Fibre ODFs>.

%#ok<*NOPTS>
