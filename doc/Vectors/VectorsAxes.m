%% Axes and Antipodal Symmetry
%
%%
% A *direction* distinguishes its two ends - north is not south. An *axis*
% does not. A plane normal is an axis when the two sides of the plane are
% physically equivalent. The rotation axis of a twofold rotation is another
% example: reversing that axis describes the same $180^\circ$ rotation.
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
% lower one. Read as an axis, |v2| is represented on the upper hemisphere by
% |-v2|. It does not become the same axis as |v1|; the two upper-hemisphere
% points remain separated.

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
% Rather than repeating the option at every symmetry-aware command, mark the
% data itself once. Operations such as |angle|, |mean| and plotting then
% honour the flag.

v2.antipodal = true;

angle(v1,v2) / degree
%
%% Densities of Axes
%
% <VectorsDensityEstimation.html Density estimation> turns a list of
% directions into a function on the sphere. A density of directed data need
% not be invariant under $v \mapsto -v$.

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
% Under Friedel's law, conventional kinematic diffraction gives the same
% intensity for opposite reflections. Pole figures measured in this way
% therefore carry antipodal symmetry. MTEX plots such pole-figure data on
% the upper hemisphere only and reads a direction annotated there as an
% axis.

mtexdata dubna silent

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
