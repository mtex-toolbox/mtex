%% CSL Boundaries
%
%%
% Most misorientations bring the two lattices at a boundary into no
% particular relation. A few do something special: a fraction of the lattice
% sites of one crystal coincide with sites of the other, and the two share a
% coincidence site lattice. The fraction is written $1/\Sigma$, so a
% $\Sigma 3$ boundary has one site in three in common - the coherent twin of
% a cubic metal is one - and the larger $\Sigma$ is, the less special the
% boundary.
%
% Such boundaries have lower energy than general ones, and they behave
% differently: they resist corrosion and cracking, and a material with many
% of them is a tougher material. Finding them in a map is the subject of
% this page.

mtexdata csl silent

% grain segmentation
[grains,ebsd] = calcGrains(ebsd);

% grain smoothing
grains = smoothBoundary(grains,5);

% plot the result
plot(grains,grains.meanOrientation)

%%
% The image quality of the pattern drops at a boundary, so plotting it
% underneath the orientations shows where the boundaries really lie,
% independently of the reconstruction.

plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
setColorRange([.5,5])

% the option 'FaceAlpha',0.4 makes the plot a bit translucent
hold on
plot(grains,grains.meanOrientation,'FaceAlpha',0.4,'linewidth',3)
hold off
%#ok<*ASGLU>

%% Detecting CSL boundaries
%
% |CSL(3,cs)| is the $\Sigma 3$ misorientation itself, so selecting the
% boundaries that carry it is a question about the angle between two
% misorientations. Three degrees is the tolerance here.

% restrict to iron to iron phase transition
gB = grains.boundary('iron','iron')

% select CSL(3) grain boundaries
gB3 = gB(angle(gB.misorientation,CSL(3,ebsd.CS)) < 3*degree);

% overlay CSL(3) grain boundaries with the existing plot
hold on
plot(gB3,'lineColor','gold','linewidth',3,'DisplayName','CSL 3')
hold off

%%
% 43 percent of the boundary segments of this map are $\Sigma 3$, and they
% are not scattered: they run as whole boundaries, straight across from one
% triple point to the next. This is a recrystallised material full of
% annealing twins.
%
% The tolerance is a choice, and the usual one is not a fixed angle. The
% Brandon criterion allows $15^\circ/\sqrt{\Sigma}$, which is 8.7 degrees
% for $\Sigma 3$ and shrinks as the coincidence gets weaker. The 3 degrees
% used here is stricter than that.

%% Triple points where CSL boundaries meet
%
% A triple point knows the three boundaries that meet in it, through
% |boundaryId|, so a condition on the boundaries becomes a condition on
% triple points. Here: the points where at least two of the three are
% $\Sigma 3$.

% logical list of CSL boundaries
isCSL3 = grains.boundary.isTwinning(CSL(3,ebsd.CS),3*degree);

% logical list of triple points with at least 2 CSL boundaries
tPid = sum(isCSL3(grains.triplePoints.boundaryId),2)>=2;

% plot these triple points
hold on
plot(grains.triplePoints(tPid),'color','red','linewidth',2,'MarkerSize',8)
hold off

%%
% These are the points where a twin lamella ends against another boundary,
% and their number is one of the measures of how twinned a material is.

%% Merging across the twins
%
% A twin belongs to the grain it grew in, so undoing the twinning means
% merging the grains that share a $\Sigma 3$ boundary - see
% <GrainMerge.html Merging Grains>.

% this merges the grains
[mergedGrains,parentIds] = merge(grains,gB3);

% overlay the boundaries of the merged grains with the previous plot
hold on
plot(mergedGrains.boundary,'linecolor','w','linewidth',3)
hold off

%%
% Many of the white outlines enclose several of the coloured grains: those
% were one grain before it twinned.
%
% The other low $\Sigma$ boundaries can be picked out the same way. Note the
% wider tolerance - 5 degrees for all of them here.

delta = 5*degree;
gB5 = gB(gB.isTwinning(CSL(5,ebsd.CS),delta));
gB7 = gB(gB.isTwinning(CSL(7,ebsd.CS),delta));
gB9 = gB(gB.isTwinning(CSL(9,ebsd.CS),delta));
gB11 = gB(gB.isTwinning(CSL(11,ebsd.CS),delta));

hold on
plot(gB5,'lineColor','b','linewidth',2,'DisplayName','CSL 5')
plot(gB7,'lineColor','g','linewidth',2,'DisplayName','CSL 7')
plot(gB9,'lineColor','m','linewidth',2,'DisplayName','CSL 9')
plot(gB11,'lineColor','c','linewidth',2,'DisplayName','CSL 11')
hold off

%%
% There are far fewer of these: 2.9 percent of the segments are $\Sigma 9$,
% 1.1 percent $\Sigma 11$, and $\Sigma 5$ and $\Sigma 7$ together fewer than
% 70 segments out of 17569. They also appear in short pieces rather than as
% whole boundaries. That $\Sigma 9$ is the most common of them is no
% accident - two $\Sigma 3$ twins meeting produce it.

%% The misorientations themselves
%
% Instead of asking whether each segment matches a given relationship, one
% can look at all the boundary misorientations at once. They live in the
% fundamental region of misorientation space, and the special ones are
% points in it.

% compute the boundary of the fundamental zone
oR = fundamentalRegion(ebsd.CS,ebsd.CS,'antipodal');
close all
plot(oR)

% plot 500 random misorientations in the 3d fundamental zone
mori = discreteSample(gB.misorientation,500);
hold on
plot(mori.project2FundamentalRegion)
hold off

% mark the CSL(3) misorientation
hold on
csl3 = CSL(3,ebsd.CS);
plot(csl3.project2FundamentalRegion('antipodal') ,'MarkerColor','r','DisplayName','CSL 3','MarkerSize',20)
hold off

%%
% The cloud is not uniform: a dense clump sits at the corner of the region,
% and the red marker of the $\Sigma 3$ misorientation sits in it.

%% The misorientation distribution function
%
% A density estimated from those misorientations makes the same statement
% quantitatively. |'antipodal'| is implied by the boundary misorientations
% themselves, since a boundary has no preferred side.

mdf = calcDensity(gB.misorientation,'halfwidth',5*degree,'bandwidth',48)

%%
% Sections at constant misorientation angle show where the density sits,
% with the low $\Sigma$ misorientations annotated.

plot(mdf,'axisAngle',(25:5:60)*degree,'colorRange',[0 15])

annotate(CSL(3,ebsd.CS),'label','$CSL_3$','backgroundcolor','w')
annotate(CSL(5,ebsd.CS),'label','$CSL_5$','backgroundcolor','w')
annotate(CSL(7,ebsd.CS),'label','$CSL_7$','backgroundcolor','w')
annotate(CSL(9,ebsd.CS),'label','$CSL_9$','backgroundcolor','w')

drawNow(gcm)

%%
% Everything is concentrated in the 60 degree section, on the $\Sigma 3$
% label. The maxima of the density confirm it:

[~,mori] = max(mdf,'numLocal',2)

%%
% And the fraction of the boundary misorientations within 2 degrees of a
% given one is available directly, without the density:

100 * volume(gB.misorientation,CSL(3,ebsd.CS),2*degree)

100 * volume(gB.misorientation,CSL(9,ebsd.CS),2*degree)

%%
% Two fifths of the misorientations are $\Sigma 3$ within 2 degrees, against
% 2 percent for $\Sigma 9$.
%
% The density can also be evaluated along a path through misorientation
% space. The three natural ones are rotations about a low index axis, and
% $\Sigma 3$ is a 60 degree rotation about <111>:

omega = linspace(0,60*degree);
fibre100 = orientation.byAxisAngle(xvector,omega,mdf.CS,mdf.SS)
fibre111 = orientation.byAxisAngle(vector3d(1,1,1),omega,mdf.CS,mdf.SS)
fibre101 = orientation.byAxisAngle(vector3d(1,0,1),omega,mdf.CS,mdf.SS)

close all
plot(omega ./ degree,mdf.eval(fibre100),'LineWidth',2)
hold on
plot(omega ./ degree,mdf.eval(fibre111),'LineWidth',2)
plot(omega ./ degree,mdf.eval(fibre101),'LineWidth',2)
hold off
legend('100','111','101')
xlabel('misorientation angle');
ylabel('mrd');

%%
% The <111> curve rises to a sharp peak of 54 mrd at exactly 60 degrees,
% while <101> stays below 3.4 and <100> below 1. One misorientation
% dominates this material, and it is the twin.
%
% Finally, the density can be evaluated at a single misorientation, which is
% how one asks "how common is this particular boundary here":

mori = orientation.byEuler(15*degree,28*degree,14*degree,mdf.CS,mdf.CS)

mdf.eval(mori)

mdf.eval(csl3)

%%
% 1.6 against 54 multiples of random: the misorientation picked at random is
% about as common as chance would make it, the twin fifty times more so.

%#ok<*ASGLU>
