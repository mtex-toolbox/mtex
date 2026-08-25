%% Plotting Rotations
%
%%
% A single rotation is best drawn by what it does, as the arrows on
% <RotationDefinition.html Definition> do. A whole set of rotations is drawn
% by giving each of them a point in a three dimensional space - one point
% per rotation, one space per parametrisation.

plottingConvention.default('y↑→x');

% 500 uniformly distributed rotations
rot = rotation.rand(500);

%% Euler Angle Space
%
% <quaternion.scatter.html |scatter|> puts each rotation at its three Bunge
% Euler angles. This is the default for rotations without a crystal
% symmetry, and the box is the range the angles run over: $2\pi$ wide in
% $\varphi_1$ and $\varphi_2$, $\pi$ deep in $\Phi$.

scatter(rot,'Bunge')

%%
% The points are not spread evenly, although the rotations are: they thin
% out towards the bottom of the box. Euler angle space distorts volume, by a
% factor $\sin\Phi$ that vanishes at both $\Phi = 0$ and $\Phi = \pi$, so
% equal boxes near those faces do not hold equal shares of rotations. This
% is why visual point density in an Euler-angle plot is not itself a texture
% density.

%% Axis Angle and Rodrigues Space
%
% The same rotations placed by their axis and angle - the direction of the
% point is the rotation axis, the distance from the centre the rotation
% angle.

scatter(rot,'axisAngle')

%%
% Now the cloud is a ball, and it is denser towards the rim: there are more
% rotations by a large angle than by a small one. Rodrigues space is the
% same construction with the distance scaled by $\tan\omega/2$, which pushes
% the $180^\circ$ rotations out to infinity.

scatter(rot,'Rodrigues')

%%
% The trade-offs between the three, and the two constructions that preserve
% volume instead, are collected in
% <RotationRepresentations.html Representations>.

%% Colour and Markers
%
% |scatter| takes the usual options, so a subset is highlighted by drawing
% it on top.

small = rot(rot.angle < 60*degree);

scatter(rot,'axisAngle','MarkerFaceColor',[.7 .7 .7],'MarkerSize',4)
hold on
scatter(small,'axisAngle','MarkerFaceColor','r')
hold off

%%
% The red points sit in a small ball around the centre, and there are few of
% them.

100 * length(small) / length(rot)

%%
% This empirical percentage fluctuates because only 500 rotations were
% drawn. For uniformly distributed rotations, the exact fraction below an
% angle $\omega$ is $(\omega - \sin\omega)/\pi$, so at $60^\circ$ it is

100 * (60*degree - sin(60*degree)) / pi

%%
% about 5.77%. What a texture calls nearly identical is therefore a small
% minority among rotations in general.

%% Next
%
% Once rotations carry a crystal symmetry the same plots are restricted to a
% <OrientationFundamentalRegion.html fundamental region>, and dense sets of
% orientations are better drawn as sections through it, see
% <OrientationVisualizationSections.html Section Plots>.

%#ok<*NOPTS>
