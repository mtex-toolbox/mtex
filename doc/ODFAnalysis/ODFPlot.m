%% Visualizing ODFs
%
%%
% An ODF is a function on a three dimensional curved space, and a sheet of
% paper is flat. Every way of drawing one is therefore a compromise, and
% there are two families of them:
%
% # parametrise orientation space by three numbers - the Euler angles, say -
% and draw a translucent three dimensional contour plot;
% # cut the space into two dimensional sections and draw the ODF on each.
%
% The second is what is normally used, and which sections are cut matters
% more than it looks.

plottingConvention.default('y↑→x');

%%
% A model ODF to draw: two sharp components and a fibre.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.1*unimodalODF(mod1) ...
  + 0.2*unimodalODF(mod2) ...
  + 0.7*fibreODF(Miller(0,0,1,cs),vector3d(1,0,0),'halfwidth',10*degree);

%%
% and let us switch to the LaboTex colormap
setMTEXpref('defaultColorMap',LaboTeXColorMap);

%% Three Dimensional Plots
%
% Visualizing an ODF in three dimensions is done by the command
% <SO3Fun.plot3d.html |plot3d|>.

plot3d(odf)

%%
% The fibre shows as a tube, the two components as blobs. Rotating such a
% plot in the figure window is the only way to read it, which is the main
% argument against it on paper.
%
% By default the ODF is drawn in Bunge Euler angle space
% $\varphi_1$, $\Phi$, $\varphi_2$. The range of the Euler angles depends
% on the crystal symmetry according to the following table
%
% || symmetry     ||    1          ||    2          ||   222         ||    3          ||   32          ||    4          ||   422         ||    6          ||   622         ||    23         ||         432   ||
% || $\varphi_1$  || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ ||
% || $\Phi$       || $180^{\circ}$ || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $90^{\circ}$  ||
% || $\varphi_2$  || $360^{\circ}$ || $180^{\circ}$ || $180^{\circ}$ || $120^{\circ}$ || $120^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $60^{\circ}$  || $60^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  ||
%
% For the last two symmetries the threefold axis is not accounted for, so
% each orientation appears three times inside the region. The first Euler
% angle is restricted by specimen symmetry only. These bounds come from
% <symmetry.fundamentalRegionEuler.html |fundamentalRegionEuler|>

[maxphi1,maxPhi,maxphi2] = fundamentalRegionEuler(crystalSymmetry('432'),specimenSymmetry('222'))

%%
% the familiar $90^{\circ} \times 90^{\circ} \times 90^{\circ}$ cube for
% cubic crystal and orthorhombic specimen symmetry. It is a *bounding box*,
% not the fundamental region itself - for cubic symmetry the box is about
% three times too large, which is why an orientation can appear in it more
% than once. Given an arbitrary orientation

ori = orientation.rand(crystalSymmetry('432'),specimenSymmetry('222'))

%%
% the symmetrically equivalent orientation within the fundamental region
% can be computed using the command <orientation.project2EulerFR.html
% project2EulerFR>

[phi1,Phi,phi2] = ori.project2EulerFR;
[phi1,Phi,phi2] ./degree

%%
% Euler angle space follows the geometry of orientation space badly: it
% stretches some regions and squeezes others, so a concentration seen there
% may be an artefact of the parametrisation. Axis angle space distorts far
% less, and for misorientations it is the usual choice - the option is
% |'axisAngle'|.

plot3d(odf,'axisAngle','figSize','large')

%% ODF Sections
%
% Plotting an ODF in two dimensional sections through the orientation space
% is done using the command <SO3Fun.plotSection.html plotSection>. By default
% the sections are at constant angles of $\varphi_2$.

plotSection(odf)

%%
% Six sections at constant $\varphi_2$, the classical view. The fibre
% appears as a line wandering from section to section, which is what makes
% these plots hard to read: one component is spread over several pictures.
%
% More on customizing them is in the chapter
% <EulerAngleSections.html Euler angle sections>. Beside the standard
% $\varphi_2$ sections MTEX supports also sections according to all other
% Euler angles.
%
% * $\varphi_2$ (default)
% * $\varphi_1$
% * $\alpha$ (Matthies Euler angles)
% * $\gamma$ (Matthies Euler angles)
% * $\sigma = \alpha + \gamma$ (recommended)
%
% Sigma sections are the recommended default. They follow the geometry of
% the space much more closely, and a component that spans several phi2
% sections usually sits in one sigma section, see
% <SigmaSections.html Sigma Sections>.

plotSection(odf,'sigma')

%% Along a Fibre
%
% A section need not be a plane. Evaluating the ODF along a curve gives the
% density itself rather than a projection of it, which is the sharpest view
% available when the curve is the right one.

close all

% select a fibre of interest
f = fibre(Miller(1,2,-3,2,cs),vector3d(2,1,1));

plot(odf,f,'LineWidth',2);


%%
% Finally, set the default colormap back.

setMTEXpref('defaultColorMap',WhiteJetColorMap);

%% Next
%
% The two section types have pages of their own,
% <EulerAngleSections.html Euler Angle Sections> and
% <SigmaSections.html Sigma Sections>. The projections onto the sphere are
% <ODFPoleFigure.html Pole Figures> and
% <ODFInversePoleFigure.html Inverse Pole Figures>.

%#ok<*NOPTS>
