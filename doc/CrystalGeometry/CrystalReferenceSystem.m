%% The Crystal Reference System
%
%%
% A crystal is described by its crystallographic axes $\vec a$, $\vec b$,
% $\vec c$ - their lengths and the angles between them. That is what
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|> is given.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree])

%% Why a Cartesian Frame is Needed as Well
%
% Those axes are in general neither perpendicular nor of equal length, while
% most MTEX computations use orthonormal Cartesian components. An orientation
% maps a Cartesian crystal frame to a Cartesian specimen frame, and tensor
% entries are likewise stated in an orthonormal basis. The lattice basis
% $\vec a$, $\vec b$, $\vec c$ must therefore be embedded in a Cartesian
% frame $\vec x$, $\vec y$, $\vec z$ - and how that is done is a convention.
%
% This page is about that embedding. Which lattice vectors are called
% $\vec a$, $\vec b$ and $\vec c$ in the first place is a second convention,
% treated in <SymmetryAlignment.html Crystal Axes Alignment>.

%% Cubic, Tetragonal and Orthorhombic Symmetry
%
% Here the crystal axes are already perpendicular, so $\vec x \parallel \vec
% a$, $\vec y \parallel \vec b$, $\vec z \parallel \vec c$ is the obvious
% choice. It is the MTEX default and needs no further specification.

%% Trigonal and Hexagonal Symmetry
%
% Now $\vec a$ and $\vec b$ enclose $120^\circ$, so at most one of them can
% be a Cartesian axis. Convention puts $\vec z$ along $\vec c$ and then has
% a choice: $\vec x$ along $\vec a$, or $\vec y$ along $\vec a$. Both are in
% use. Their Cartesian frames are rotated by $90^\circ$; crystal symmetry
% will reduce the orientation difference to $30^\circ$ below.

cs_x2a = crystalSymmetry('321',[1.7,1.7,1.4],'X||a','Z||c');

% visualize the results
plot(cs_x2a,'figSize','small')
annotate(cs_x2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_x2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')

%%
% The other setup, with $\vec y$ along $\vec a$:

cs_y2a = crystalSymmetry('321',[1.7,1.7,1.4],'y||a','Z||c');

plot(cs_y2a,'figSize','small')
annotate(cs_y2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_y2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')

%%
% The two plots differ only in where the green $\vec x$ and $\vec y$ markers
% sit - the a-axis stays put. That is because a plot in crystal coordinates,
% an inverse pole figure for instance, is aligned on screen by the a- or
% b-axis, not by $\vec x$.
%
% The transformation matrix between the two Cartesian crystal frames makes
% their $90^\circ$ offset explicit.

frameOffset = angle(rotation.byMatrix(...
  transformationMatrix(cs_x2a,cs_y2a))) ./ degree

%%
% That on-screen alignment belongs to the crystal frame and is changed
% there.

% change on screen alignment
cs_y2a.frame.how2plot.east = cs_y2a.bAxis;

%%

plot(cs_y2a,'figSize','small')
annotate(cs_y2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_y2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')

%% What the Choice Changes
%
% The lattice and its indexed geometry do not change, but their Cartesian
% coordinates do. Drawn against fixed Cartesian axes, the same indexed quartz
% shape is therefore expressed differently in the two setups.

cS_x2a = crystalShape.quartz(cs_x2a);

close all
figure(1)
plot(cS_x2a,'figSize','small','colored')
hold on
arrow3d(0.6*[vector3d.X,vector3d.Y,vector3d.Z],'labeled')
hold off

%%

cS_y2a = crystalShape.quartz(cs_y2a);

figure(2)
plot(cS_y2a,'figSize','small','colored')
hold on
arrow3d(0.6*[vector3d.X,vector3d.Y,vector3d.Z],'labeled')
hold off

%%
% The consequence is sharpest for Euler angles. They parameterise the map
% between Cartesian crystal and specimen frames, so the same three numbers
% describe two different physical orientations when the crystal frame is
% changed. Here the convention is stated explicitly as Bunge.

ori_x2a = orientation.byEuler(0,0,0,'Bunge',cs_x2a)

%%

ori_y2a = orientation.byEuler(0,0,0,'Bunge',cs_y2a)

%%

newMtexFigure('innerPlotSpacing',20,'figSize','small')
plotPDF(ori_x2a,Miller(1,0,0,cs_x2a),'MarkerSize',20)
annotate([vector3d.X,vector3d.Y],'label',{'x','y'},'backgroundColor','w')
nextAxis
plotPDF(ori_y2a,Miller(1,0,0,cs_y2a),'MarkerSize',20)
annotate([vector3d.X,vector3d.Y],'label',{'x','y'},'backgroundColor','w')

%%
% The two pole figures are the same pattern turned by $30^\circ$. When the
% orientations are compared, MTEX first reports that it is transforming the
% differing reference systems. The returned angle is the smallest difference
% after applying the |321| crystal symmetry, not the raw frame rotation shown
% above.

symmetryReducedDifference = angle(ori_x2a,ori_y2a) ./ degree

%%
% Thus, for this example, assigning the same Euler triplets under the wrong
% setup produces a $30^\circ$ crystallographic error even though the frame
% correction itself is $90^\circ$. This is easy to miss if only crystal
% symmetry-reduced angles are inspected.

%% Converting Between Setups
%
% MTEX recognises differing setups in many places and corrects for them. To
% do it explicitly, <orientation.transformReferenceFrame.html
% |transformReferenceFrame|> rewrites an orientation in another frame
% *without* changing the orientation it describes. Here |ori_x2a| is
% expressed in the |y||a| setup.

oriConverted = ori_x2a.transformReferenceFrame(cs_y2a)

%%
% The Euler angles came out different, as they must - the same physical
% orientation read in a Cartesian crystal frame turned by $90^\circ$. What
% has not changed is
% where the crystal points, so this is not the same orientation as
% |ori_y2a|, which carries the same Euler angles as |ori_x2a| instead.

sameSpecimenDirection = angle(...
  ori_x2a * Miller(1,0,0,cs_x2a,'uvw'),...
  oriConverted * Miller(1,0,0,cs_y2a,'uvw')) < 1e-5*degree

%%
% The logical result is true: after conversion, the indexed direction points
% to the same specimen direction despite the changed numerical description.

%% Triclinic and Monoclinic Symmetry
%
% For a general triclinic or monoclinic metric, the direct axes do not form a
% complete orthonormal triad. A Cartesian frame is commonly fixed by aligning
% one Cartesian axis with a direct axis and another with a *reciprocal* axis,
% which is perpendicular to the other two direct axes by construction. Both
% of the following setups are found in the wild for the same mineral.

cs = crystalSymmetry('-1', [8.290 12.966 7.151], [91.18 116.31 90.14]*degree,...
  'x||a*','y||b', 'mineral','An0 Albite 2016')

%%

cs = crystalSymmetry('-1', [8.290 12.966 7.151], [91.18 116.31 90.14]*degree,...
  'x||a','c||c*', 'mineral','An0 Albite 2016')

%%
% The display of a |crystalSymmetry| always states which setup it uses, so
% the answer to "which convention is this data in?" is in the printout of
% the symmetry itself.

%% Next
%
% Which lattice vector is called $\vec a$ at all, and the conventions
% different laboratories use, is <SymmetryAlignment.html Crystal Axes
% Alignment>. Directions written in the resulting crystal frame are
% <CrystalDirections.html Miller Indices>.

%#ok<*NASGU>
%#ok<*NOPTS>
