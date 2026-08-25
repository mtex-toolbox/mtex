%% EBSD Orientation Analysis
%
%%
% This page throws the map away and works with the orientations alone -
% what they are, not where they are. For the spatial side see
% <EBSDProfile.html Profiles>. The example is a question with a wrong
% answer in it: does this rock have a fibre texture?

plottingConvention.default('y↑→x');
mtexdata forsterite silent

plot(ebsd)

%% A first look at the pole figures
%
% Three pole figures of the forsterite phase, one per crystal axis.

cs = ebsd('Forsterite').CS % the crystal symmetry of the forsterite phase
h = [Miller(1,0,0,cs),Miller(0,1,0,cs),Miller(0,0,1,cs)];
plotPDF(ebsd('Forsterite').orientations,h,'antipodal')

%%
% The $(100)$ axes lie on a great circle rather than in a spot. That is
% what a *fibre texture* looks like: all crystals share one direction and
% are otherwise free to turn about it. The hypothesis is worth testing.
%
%% Finding the axis
%
% If the $(100)$ axes really lie on a great circle, there is a direction
% orthogonal to all of them, and |perp| finds the one that comes closest.

% the orientations of the Forsterite phase
ori = ebsd('Forsterite').orientations
% the vectors in the 100 pole figure
r = ori * Miller(1,0,0,ori.CS)

% the vector best orthogonal to all r
rOrth = perp(r)

% output
plot(rOrth,'add2all','Marker','square','markerColor','DarkRed')

%%
% The square marks that direction in each of the three pole figures. In the
% $(100)$ figure it lies well away from the data, as the pole of a great
% circle must - and in the $(010)$ figure it lands in the middle of the
% densest cluster, which is a hint worth coming back to. Drawing the band
% that reaches to within 10° of the great circle makes the claim checkable.

nextAxis(1)
circle(rOrth,80 * degree,'lineColor','darkred','linewidth',5,'EdgeAlpha',0.5)

%%
% And counting how much of the data falls inside that band turns it into a
% number, in percent.

100 * sum(angle(r,rOrth)>80*degree) / length(ori)

%%
% Nearly 62% of the measurements have their $a$ axis within 10° of the
% great circle. For a first test that looks convincing.
%
%% Which crystal direction is the fibre axis
%
% A fibre needs a crystal direction as well as a specimen direction: it is
% the set of orientations that map a fixed crystal direction onto a fixed
% specimen direction. The inverse pole figure of |rOrth| says which crystal
% direction that would have to be.

plotIPDF(ebsd('Forsterite').orientations,rOrth,'smooth')
mtexColorbar

%%
% The density piles up near $(010)$, so the candidate is the fibre that
% takes the crystal $b$ axis to |rOrth|. Its volume is the honest version
% of the number above.

% define the fibre
f = fibre(Miller(0,1,0,cs),rOrth);

% compute the volume along the fibre
100 * volume(ebsd('Forsterite').orientations,f,10*degree)

%%
% 28%, less than half of the 62%, and the difference is the whole point.
% Lying in the girdle only says that the $a$ axis avoids |rOrth|; the fibre
% says in addition that the $b$ axis *points at* it. Every orientation on
% the fibre is in the girdle, but most of the girdle is not on the fibre.
%
%% What the ODF says
%
% A fibre texture is constant along its fibre. Estimating a density from
% the orientations and following it along |f| tests exactly that -
% see <EBSD2ODF.html ODF Estimation> for what |calcDensity| does.

odf = calcDensity(ebsd('Forsterite').orientations)

% plot the odf along the fibre
plot(odf,f,'linewidth',2)
ylim([0,26])

%%
% A fibre texture would give a flat line. This one swings between 5.5 and
% 19.6 times uniform, a factor of three and a half, with two peaks in every
% half turn. Together with the 28% that settles the question: there is no
% fibre texture here, only a few strong components that happen to share a
% plane.
%
%% Why the peaks are there
%
% Plotting the whole density in sections of orientation space shows where
% they come from.

plot(odf,'sigma')

%%
% These are the large isolated spots that a map with few grains always
% produces: each grain contributes thousands of nearly identical
% orientations, so one grain becomes one peak, and the estimated density
% describes the grains that were measured rather than the rock they came
% from. For texture analysis a coarser step over a larger area would have
% been the better measurement.
%
