%% Tilt and Twist Boundaries
%
%%
% If a material deforms through the movement of dislocations, rearrangement
% of dislocations to a low-energy configuration may happen during
% deformation (i.e. in slow, geologic deformation) or or afterwards (in
% many metals). In any case, the arrangement of dislocation walls can lead
% to so-called subgrains boundaries. If such a boundary is composed of edge
% dislocations, it is called a tilt boundary and the rotation axis relating
% both parts of the grain at each side can be expected to be within the
% boundary plane (ideally parallel to the edge dislocation line). If the
% boundary is composed of screw dislocations, the rotation axis should be
% normal to the boundary. Between those end-members, there are general
% boundaries where the rotation axis is not easily related to the type of
% dislocations unless further information is available.
%
% In this chapter we discuss the computation of the misorientation axes at
% subgrain boundaries and discuss whether they vote for twist or tilt
% boundaries. We start by importing an sample EBSD data set and computing
% all subgrain boundaries as it is described in more detail in the chapter
% <subGrainBoundaries.html Subgrain Boundaries>.

% load some test data
mtexdata forsterite silent

% remove one pixel grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize<5)) = [];

% compute subgrain boundaries with 1.5 degree threshold angle
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',[1*degree, 15*degree]);

% lets smooth the grain boundaries a bit
grains = smooth(grains,5);

% set up the ipf coloring
cKey = ipfColorKey(ebsd('fo').CS.properGroup);
cKey.inversePoleFigureDirection = xvector;
color = cKey.orientation2color(ebsd('fo').orientations);

% plot the forsterite phase
plot(ebsd('fo'),color,'faceAlpha',0.5,'figSize','large')

% init override mode
hold on

% plot grain boundares
plot(grains.boundary,'linewidth',2)

% compute transparency from misorientation angle
alpha = grains('fo').innerBoundary.misorientation.angle / (5*degree);

% plot the subgrain boundaries
plot(grains('fo').innerBoundary,'linewidth',1.5,'edgeAlpha',alpha,'linecolor','b');

% stop override mode
hold off

%%
% In the above plot we have marked all subgrain boundaries in blue and
% adjusted the transparency value according to the misorientation angle.
%
%% Misorientation Axes
%
% When analysing the misorientation axes of the subgrain boundary
% misorientations we need to distinguish whether we look at the
% misorientation axes in crystal coordinates or in specimen coordinates.
% Lets start with the misorientation axes in crystal coordinates which can
% directly be computed by the command <orientation.axis.html |axis|>.

% extract the Forsterite subgrain boundaries
subGB = grains('fo').innerBoundary;

% plot the misorientation axes in the fundamental sector
plot(subGB.misorientation.axis,'fundamentalRegion','figSize','small')

%%
% Obviously from the above plot it is not easy to judge about prefered
% misorientation axes. We get more insight if we <DensityEstimation.html
% compute the density distribution> of the misorientation axes and look for
% <S2FunOperations.html#4 local extrema>.

% compute the density distribution of misorientation axes
density = calcDensity(subGB.misorientation.axis,'halfwidth',3*degree);

% plot them
plot(density,'figSize','small')
mtexColorbar

% find the two prefered misorientation axes
[~,hkl] = max(density,'numLocal',2); round(hkl)

%%
% We find two preferred misorientation axes - (001) and (071). *TODO*: can
% this be interpreted?
% 
%% The misorientation axis in specimen coordinates
%
% The computation of the misorientation axis in specimen coordinates is a
% little bit more complicated as it is impossible using only the
% misoriention. In fact we require the adjacent orientations on both sides
% of the subgrain boundaries. We can find those by making use of the
% |ebsdId| stored in the grain boundaries. The command

oriGB = ebsd('id',subGB.ebsdId).orientations

%%
% results in a $N \times 2$ matrix of orientations with rows corresponding
% to the boundary segments and two columns for both sides of the boundary.
% The misorientation axis in specimen coordinates is again computed by the
% command <orientation.axis.html |axis|>

axS = axis(oriGB(:,1),oriGB(:,2),'antipodal')

% plot the misorientation axes
plot(axS,'MarkerAlpha',0.2,'MarkerSize',2,'figSize','small')

%%
% We have used here the option |antipodal| as we have no fixed ordering of
% the grains at the two sides of the grain boundaries. For a more
% quantitative analysis we again compute the corresponding density
% distribution and find the preferred misorientation axes in specimen
% coordinates

density = calcDensity(axS,'halfwidth',5*degree);
plot(density,'figSize','small')
mtexColorbar

[~,pos] = max(density)
annotate(pos)

%% Tilt and Twist Boundaries
%
% Subgrain boundaries are often assumed to form during deformation by the
% accumulation of edge or screw dislocations. In first extremal case of
% exclusive edge dislocations the misorientation axis is parallel to
% deformation line and within the boundary plane. Such boundaries are
% called *tild boundaries*. In the second extremal case of exclusive screw
% dislocations the misorientation axis is the screw axis and is parallel to
% the boundary axis. Such boundaries are called *twist boundaries*. 
%
% In the case of 2d EBSD data one usually has not full boundary
% information, but only the trace of the boundary with the measurement
% surface. Hence, it is impossible to distinguish tilt and twist
% boundaries. However, for twist boundaries the trace must be always
% perpendicular to the trace of the boundary as the trace is always
% perpendicular to the boundary normal. This can be easily checked from our
% EBSD data and allows us to exclude certain boundaries to be tilt
% boundaries. To do so we colorize in the following plot all subgrain
% boundaries according to the angle between the boundary trace and the
% misorientation axis. Red subgrain boundaries indicate potential tilt
% boundaries while blue subgrain boundaries are for sure no tilt
% boundaries.

plot(ebsd('fo'),color,'faceAlpha',0.5,'figSize','large')

% init override mode
hold on

% plot grain boundares
plot(grains.boundary,'linewidth',2)

% colorize the subgrain boundaries according the angle between boundary
% trace and misorientation axis
plot(subGB,angle(subGB.direction,axS)./degree,'linewidth',2)
mtexColorMap blue2red
mtexColorbar

hold off
