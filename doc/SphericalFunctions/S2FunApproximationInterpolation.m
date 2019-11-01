%% Spherical Approximation and Interpolation
%

%%
% Given data nodes

load(fullfile(mtexDataPath, 'vector3d', 'smiley.mat'));

scatter(nodes, f, 'upper');

%% Interpolation!
%

sFTri = interp(nodes, f, 'linear');

%%
% Very wow!

norm(eval(sFTri, nodes)-f)

%%
% Plotting it is meh

contourf(sFTri, 'upper');

%% Approximation?

sF = interp(nodes, f, 'harmonicApproximation');

%%
% Error meh

norm(eval(sF, nodes)-f)

%%
% Plot wow!

contourf(sF, 'upper');

