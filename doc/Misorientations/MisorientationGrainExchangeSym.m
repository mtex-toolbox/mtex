%% Grain Exchange Symmetry
%
%%
% A <MisorientationTheory.html misorientation> is defined between a first
% and a second crystal. Between two grains of the *same* phase there is
% nothing that makes one of them the first: swapping the two replaces the
% misorientation by its inverse, and no measurement can tell the two apart.
% This is *grain exchange symmetry*, and it is a symmetry of the data, not
% of the crystal.
%
% MTEX carries it in the same |antipodal| flag that distinguishes an axis
% from a direction, see <VectorsAxes.html Axes and Antipodal Symmetry> -
% for misorientations it identifies a rotation with its inverse, which in
% axis-angle terms is the same angle about the opposite axis.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('622');

%% Without the Flag
%
% Take a misorientation and its inverse.

mori = orientation.byAxisAngle(Miller(1,2,-3,1,cs),40*degree,cs,cs);

angle(mori,inv(mori)) ./ degree

%%
% Fourteen degrees apart, so MTEX regards them as different misorientations.
% That is the right answer between two different phases, where "first" and
% "second" mean something - the parent and the child of a transformation,
% say.

%% With the Flag
%
% Setting |antipodal| declares the order arbitrary, and the two become the
% same misorientation.

mori.antipodal = true;

angle(mori,inv(mori)) ./ degree

%%
% The class of equivalent misorientations doubles accordingly, from the
% $12 \times 12$ symmetry combinations to twice as many.

length(mori.symmetrise)

%%
% And the <OrientationFundamentalRegion.html fundamental region> in which
% they are drawn shrinks, since it now holds one representative of a larger
% class.

length(fundamentalRegion(cs,cs).N)

%%

length(fundamentalRegion(cs,cs,'antipodal').N)

%% Where it Happens by Itself
%
% Boundary misorientations between grains of one phase get the flag from
% MTEX without being asked.

mtexdata twins silent

grains = calcGrains(ebsd,'threshold',5*degree,'minPixel',5);

grains.boundary('Mag','Mag').misorientation.antipodal

%%
% Between two phases the flag stays off, because there the order is the
% physical one - from the first phase to the second.

mtexdata forsterite silent

grains = calcGrains(ebsd);

grains.boundary('Fo','En').misorientation.antipodal

%%
% The same distinction applies to a misorientation between a grain mean and
% the orientations inside that grain: there the order is fixed, so the flag
% belongs off.

%% Next
%
% What the flag does to the region misorientations are drawn in is
% <OrientationFundamentalRegion.html Fundamental Region>, and its effect on
% the distributions is visible in
% <AxisDistributionFunction.html Axis Distribution>.

%#ok<*NOPTS>
