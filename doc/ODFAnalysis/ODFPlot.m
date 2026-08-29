%% Visualizing ODFs
%
%% Choosing a View
%
% An orientation distribution function (ODF) is a density on the
% three-dimensional curved space of rotations. No flat picture can preserve
% all of that geometry, so every ODF plot answers a particular question.
%
% This page assumes the normalization in <ODFTheory.html ODF Theory> and
% the model components in <ODFModeling.html ODF Modeling>. The rotation
% coordinates themselves are introduced in
% <RotationRepresentations.html Rotation Representations>.
%
% There are two direct ways to draw an ODF:
%
% # parametrize orientation space by three coordinates and draw an
% isodensity surface in three dimensions;
% # cut orientation space into two-dimensional sections and draw the ODF
% value on each section.
%
% Sections are the usual choice for a printed ODF because no feature can be
% hidden behind another panel. Which sections are cut matters more than it
% looks.
%
% Pole figures and inverse pole figures are different. They are projections
% that integrate the ODF along a curve, whereas a section evaluates the ODF
% on a slice. The color in every plot below represents density in multiples
% of a random distribution (mrd), not a volume fraction at one orientation.
%
% A *plotting convention* states how the specimen reference frame is laid
% out on screen. The convention below draws Y upward and X to the right. It
% does not rotate the ODF or change its reference frame.

plottingConvention.default('y↑→x');

%% A Model with Known Features
%
% The same normalized model is used in every view. It contains two
% localized components and one fibre component, with mixture fractions
% 0.1, 0.2, and 0.7.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.1*unimodalODF(mod1) ...
  + 0.2*unimodalODF(mod2) ...
  + 0.7*fibreODF(Miller(0,0,1,cs),vector3d.X,...
  'halfwidth',10*degree);

%% Three-Dimensional Bunge Plot
%
% <SO3Fun.plot3d.html |plot3d|> with |'Bunge'| uses the Euler angles
% $(\varphi_1,\Phi,\varphi_2)$ as Cartesian plot coordinates.

plot3d(odf,'Bunge','figSize','large');
mtexColorMap('LaboTeX');
mtexColorbar('title','mrd');

%%
% The fibre forms extended tubes, while the localized components form
% compact blobs. Several symmetry-equivalent appearances can lie in the
% rectangular Euler plotting box; they are not additional components.
% Rotate this figure interactively to see features hidden behind one
% another. That need for interaction is the main weakness of a 3-D plot on
% a page. Euler coordinates also stretch some regions and squeeze others,
% so an apparent volume in this box may be a parametrization artefact.

%% Three-Dimensional Axis--Angle Plot
%
% The |'axisAngle'| flag plots the scaled-axis vector
%
% $$ \mathbf{r}=\omega\mathbf{n}, $$
%
% where $\mathbf{n}$ is the rotation axis and $\omega$ is the rotation
% angle of a symmetry-reduced representative.

plot3d(odf,'axisAngle','figSize','large');
mtexColorMap('LaboTeX');
mtexColorbar('title','mrd');

%%
% The same tube and blobs now occupy a compact, curved fundamental region.
% Radial distance has the useful meaning of rotation angle, but apparent
% volume is still distorted. Axis--angle coordinates are not an
% equal-volume map. They are often easier to interpret for
% misorientations; <OrientationVisualization3d.html 3D Orientation
% Visualizations> also compares Rodrigues, homochoric, and cubochoric
% coordinates.

%% Classical Euler Sections
%
% <SO3Fun.plotSection.html |plotSection|> evaluates the ODF on a stack of
% two-dimensional slices. The explicit |'phi2'| flag selects the classical
% sections of constant third Bunge Euler angle $\varphi_2$. By default the
% sections are at constant angles of $\varphi_2$.

plotSection(odf,'phi2','figSize','large');
mtexColorMap('LaboTeX');
mtexColorbar('title','mrd');

%%
% The six panels are successive slices, not six projections. Following the
% fibre from panel to panel traces a line through orientation space, while
% each localized component occupies only nearby slices. This splitting is
% why a component can be difficult to recognize from one panel alone.
%
% <EulerAngleSections.html Euler Angle Sections> explains how to choose the
% panel values and layout. MTEX also supports sections of constant
% $\varphi_1$ or $\Phi$ in the Bunge convention, and constant $\alpha$ or
% $\gamma$ in the Matthies convention.

%% Sigma Sections
%
% Sigma sections reorganize the same three orientation coordinates around
% a selected crystal axis. MTEX uses the Matthies coordinate
% $\sigma=\alpha+\gamma$. Do not identify it with the informal Bunge-angle
% expression $\varphi_1-\varphi_2$ sometimes attached to these plots.

plotSection(odf,'sigma','figSize','large');
mtexColorMap('LaboTeX');
mtexColorbar('title','mrd');

%%
% The localized components occupy compact regions, while the model fibre
% reaches the rim in successive panels. Sigma sections are not a
% universally superior replacement for the classical view. They are often
% especially compact for trigonal, tetragonal, and hexagonal symmetry,
% where one crystal axis is distinguished. A component spread over several
% $\varphi_2$ sections may then be easier to follow in one sigma section.
% <SigmaSections.html Sigma Sections> develops this geometric reading.

%% Along a Fibre
%
% A section need not be a plane. Evaluating the ODF along a curve returns
% the density itself rather than a projection. This is the sharpest view
% when the chosen fibre expresses the physical question.

close all;

% select a fibre of interest
f = fibre(Miller(1,2,-3,2,cs),vector3d(2,1,1));

plot(odf,f,'LineWidth',2);

%%
% The curve contains two pronounced peaks separated by low-density
% intervals. The vertical axis is the ODF value in mrd, so this trace can
% compare densities along the chosen fibre directly. It does not collect
% density from neighbouring orientations as a pole-figure projection does.

%% Euler Plotting Bounds and Symmetry
%
% The Bunge plot uses a rectangular bounding box whose angle ranges depend
% on crystal and specimen symmetry. The bounds used by MTEX are
%
% || symmetry     ||    1          ||    2          ||   222         ||    3          ||   32          ||    4          ||   422         ||    6          ||   622         ||    23         ||         432   ||
% || $\varphi_1$  || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ ||
% || $\Phi$       || $180^{\circ}$ || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $90^{\circ}$  ||
% || $\varphi_2$  || $360^{\circ}$ || $180^{\circ}$ || $180^{\circ}$ || $120^{\circ}$ || $120^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $60^{\circ}$  || $60^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  ||
%
% With identity specimen symmetry, the first Euler angle remains
% $360^{\circ}$; crystal symmetry alone does not reduce it. Specimen
% symmetry can restrict this angle, with the final bound depending on the
% symmetry pair. For point groups 23 and 432, this box does not account for
% the threefold axis. Each orientation can therefore appear three times
% within the box. <symmetry.fundamentalRegionEuler.html
% |fundamentalRegionEuler|> returns these plotting bounds.

csCubic = crystalSymmetry('432');
ssOrtho = specimenSymmetry('222');
[maxPhi1,maxPhi,maxPhi2] = fundamentalRegionEuler(csCubic,ssOrtho);
eulerBounds = [maxPhi1,maxPhi,maxPhi2] ./ degree

%%
% The displayed result is the familiar cube with bounds $90^{\circ}$ by
% $90^{\circ}$ by $90^{\circ}$ for cubic crystal and orthorhombic specimen
% symmetry.
% It is a bounding box, not the fundamental region itself. For cubic
% symmetry the box has about three times the volume needed for one
% representative, which explains the repeated appearances in the first
% figure.
%
% Given an arbitrary orientation, <orientation.project2EulerFR.html
% |project2EulerFR|> selects a symmetry-equivalent representative inside
% this Euler box.

ori = orientation.rand(csCubic,ssOrtho);
[phi1,Phi,phi2] = ori.project2EulerFR;
projectedEuler = [phi1,Phi,phi2] ./ degree

%%
% All three displayed coordinates lie between $0^{\circ}$ and
% $90^{\circ}$. This representative is suitable for the Euler plotting
% box, but the box still contains symmetry-related duplicates elsewhere.
% <OrientationFundamentalRegion.html Fundamental Regions> constructs the
% compact symmetry-reduced region used by the axis--angle plot.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, develops ODFs, Bunge Euler space, and classical section plots.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, treats rotation parametrizations, symmetry, and asymmetric domains.
% * S. Matthies, K. Helming, and K. Kunze,
% <https://doi.org/10.1002/pssb.2221570105 On the Representation of
% Orientation Distributions in Texture Analysis by Sigma-Sections. I>,
% _physica status solidi (b)_ 157 (1990), 71--83, introduces sigma
% sections. <https://doi.org/10.1002/pssb.2221570202 Part II>, 489--507,
% develops crystal and specimen symmetry and worked examples.

%% Next
%
% The section families have detailed pages,
% <EulerAngleSections.html Euler Angle Sections> and
% <SigmaSections.html Sigma Sections>. The projections onto the sphere are
% <ODFPoleFigure.html Pole Figures> and
% <ODFInversePoleFigure.html Inverse Pole Figures>. Use
% <ODFCharacteristics.html Properties> when the result should be a number
% rather than another view.

%#ok<*NOPTS>
