%% 3D Orientation Visualizations
%
%%
% A <OrientationPoleFigure.html pole figure> shows one crystal direction and
% throws the rest away. The alternative is to give every orientation a point
% in a three dimensional space and draw them all - nothing is lost, at the
% price of a plot that has to be turned to be read.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('cubic')

ori = orientation.rand(100,cs);

%% Euler Angle Space
%
% <orientation.plot.html |plot|> places each orientation at its three Bunge
% Euler angles.

plot(ori)

%%
% The box is smaller than the full range of the angles, because the
% orientations are projected into the fundamental region first - for cubic
% symmetry $\Phi$ and $\varphi_2$ run to $90^\circ$ rather than to $180^\circ$
% and $360^\circ$. Every orientation outside has an equivalent one inside,
% so nothing is hidden by this, see
% <OrientationFundamentalRegion.html Fundamental Region>.
%
% Drawing them where their Euler angles say instead is |'ignoreFundamentalRegion'|.

plot(ori,'ignoreFundamentalRegion')

%%
% The cloud now fills the whole box. Note how the points thin out towards
% $\Phi = 0$: Euler angle space distorts volume, so a cluster there is not
% as concentrated as it looks.

%% Axis Angle Space
%
% The other choice places an orientation in the direction of its rotation
% axis, at a distance given by its rotation angle.

plot(ori,'AxisAngle','markerEdgeColor',[0 0 0.8],'markerSize',8)

%%
% Here the fundamental region is not a box but a polyhedron, and drawing it
% alongside the unprojected orientations shows what the projection does.

plot(ori,'axisAngle','ignoreFundamentalRegion','markerEdgeColor',[0 0 0.8],'markerSize',8)

% visualize the fundamental region
hold on
oR = fundamentalRegion(ori.CS,ori.SS)
plot(oR,'color',[1 0.5 0.5])
hold off

%%
% The points outside the solid are the ones the previous plot moved inside.
% Axis angle space is the more faithful of the two - it distorts volume far
% less than Euler space - which is why it is the default for misorientations.

%% Next
%
% Two dimensional cuts through these spaces, which is how dense data is
% usually read, are
% <OrientationVisualizationSections.html Section Plots>. The shape of the
% region itself is <OrientationFundamentalRegion.html Fundamental Region>,
% and the merits of the different parametrisations are compared in
% <RotationRepresentations.html Representations>.

%#ok<*NOPTS>
