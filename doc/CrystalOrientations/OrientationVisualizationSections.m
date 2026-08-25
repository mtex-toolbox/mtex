%% Orientation Sections
%
%%
% A three dimensional cloud of orientations is hard to read on paper, so the
% usual compromise is a stack of two dimensional slices through orientation
% space. Which slices, and how they are cut, is a matter of convention -
% each of them keeps some structure recognisable and hides other.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('432')
ss = specimenSymmetry('222')

ori = orientation.rand(100,cs,ss)

%% phi2 Sections
%
% The most common cut fixes the third Euler angle. Each plot is one value of
% $\varphi_2$, with $\varphi_1$ and $\Phi$ spanning the plane.

plotSection(ori,'phi2')

%%
% The points have no preferred orientation, but they are not uniform in the
% rectangular Euler coordinates: the volume element contains
% $\sin\Phi$, so points thin out near $\Phi=0$. Real textures add structure
% on top of that baseline, as spots or lines running through several
% sections. The classical rolling fibres of cubic metals are read this way,
% see <EulerAngleSections.html Euler Angle Sections>.

%% Sigma Sections
%
% Sigma sections cut differently, along $\sigma = \varphi_1 - \varphi_2$.
% They need fewer plots to cover the same region and keep a texture
% component together instead of splitting it across sections.

plotSection(ori,'sigma')

%%
% Why they are the better default for cubic material, and how to read them,
% is <SigmaSections.html Sigma Sections>.

%% Further Section Types
%
% |plotSection| also takes |'phi1'| for sections of the first Euler angle
% and |'axisAngle'| for sections of constant rotational angle. The number of
% sections is set with the option |'sections'|.

plotSection(ori,'axisAngle','sections',6)

%%
% Sections of a *density* rather than of a list of orientations are the same
% plots applied to an ODF, which is what these views are mostly used for -
% see <ODFPlot.html Plotting an ODF>. Do not contour a scatter of
% orientations directly: computing an ODF first and plotting that is both
% faster and better founded, and MTEX warns when asked to do otherwise.

%% Next
%
% The full three dimensional views these sections cut through are
% <OrientationVisualization3d.html 3D Plots>.

%#ok<*NOPTS>
