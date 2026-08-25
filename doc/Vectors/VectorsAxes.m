%% Axes and Antipodal Symmetry
%
%%
% A *direction* distinguishes its two ends - north is not south. An *axis*
% does not. The normal of a lattice plane is an axis, because the plane has
% no preferred side, and so is the axis of a twofold rotation, because
% turning by $180^\circ$ one way and the other gives the same result.
%
% MTEX stores both as a <vector3d.vector3d.html |@vector3d|> and keeps the
% difference in a single flag, |antipodal|. Setting it means: |v| and |-v|
% are the same thing.

plottingConvention.default('y↑→x');

%% Setting the Flag
%
% Take a pair of directions that differ only in the sign of their z
% coordinate.

v1 = vector3d(1,1,2);
v2 = vector3d(1,1,-2);

plot([v1,v2],'label',{'v_1','v_2'},'grid','on')

%%
% They plot on opposite hemispheres, |v1| on the upper one and |v2| on the
% lower one. Read as axes, |v2| is the same axis as |-v2|, which points
% upwards, and both mark the same spot.

plot([v1,v2],'label',{'v_1','v_2'},'antipodal','grid','on')

%% The Angle Between Axes
%
% Two axes are never more than $90^\circ$ apart, because the angle is
% measured to whichever end is closer. Without the flag,

angle(v1,v2) / degree

%%
% and with it

angle(v1,v2,'antipodal') / degree

%%
% $180^\circ$ minus the first answer. This is the quiet way to get a
% plausible wrong number: nothing complains if the flag is missing, the
% angle simply comes out obtuse where it should not be. The same holds for
% the <vector3d.mean.html mean> of a list, which cancels itself out if half
% the axes are written with one sign and half with the other.
%
%% Attaching the Flag to the Data
%
% Rather than repeating the option at every command, mark the data itself
% once. Every operation that follows honours the flag.

v2.antipodal = true;

angle(v1,v2) / degree
%
%% Densities of Axes
%
% <VectorsDensityEstimation.html Density estimation> turns a list of
% directions into a function on the sphere. For directions, that function
% can be anything.

v = vector3d.rand(100);
density = v.calcDensity;
plot(density)

%%
% For axes it cannot: a density of axes has to give |v| and |-v| the same
% value, so it is symmetric under inversion by construction. Note how the
% lower half of the plot below is the point reflection of the upper one.

density = v.calcDensity('antipodal');
plot(density,'complete')

%% Experimental Pole Figures
%
% Diffraction cannot tell a lattice plane from its back side - this is
% Friedel's law - so measured pole figures always carry antipodal symmetry.
% MTEX therefore plots pole figure data on the upper hemisphere only, and
% reads any direction annotated to such a plot as an axis.

mtexdata dubna

CS = pf.CS;

plot(pf({1}))

%%
% The annotated direction was given pointing downwards, and appears on the
% upper hemisphere.

annotate(vector3d(1,0,-1),'labeled','backgroundColor','w')

%% Pole Figures Computed from an ODF
%
% A pole figure computed from an ODF is under no such constraint, and in
% general the two hemispheres differ. Here the |(122)| pole figure and the
% one of the opposite normal are not the same.

o = orientation.byEuler(20*degree,30*degree,0,'ZYZ',CS);

odf = unimodalODF(o);

plotPDF(odf,[Miller(1,2,2,CS),-Miller(1,2,2,CS)])

%%
% To compare such a computation with a measurement, add the antipodal
% symmetry that the measurement has.

plotPDF(odf,Miller(1,2,2,CS),'antipodal')

%% Inverse Pole Figures
%
% The same reasoning applies to inverse pole figures. A complete one has no
% antipodal symmetry,

plotIPDF(odf,[vector3d.Y,-vector3d.Y],'complete','noLabel')

%%
% and enforcing the flag makes both halves equal.

plotIPDF(odf,vector3d.Y,'antipodal','complete','noLabel')

%%
% Inverse pole figures are usually not drawn complete but reduced to the
% <FundamentalSector.html fundamental sector>, the patch of the sphere that
% crystal symmetry leaves inequivalent. Antipodal symmetry shrinks that
% sector further, so the two plots below cover different regions of the
% sphere.

plotIPDF(odf,vector3d.Y)

%%

plotIPDF(odf,vector3d.Y,'antipodal')

%% Next
%
% <VectorsDensityEstimation.html Density Estimation> works throughout with
% the c-axes of an EBSD map, which are axes in exactly this sense.
% Antipodal symmetry appears again for crystal directions in
% <CrystalDirections.html Miller indices> and for misorientation axes in
% <MisorientationTheory.html Misorientations>.
