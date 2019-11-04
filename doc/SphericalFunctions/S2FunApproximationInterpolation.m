%% Spherical Approximation and Interpolation
%

%%
% On this page, we want to cover the topic of function approximation from discrete values on the sphere.
% To simulate this, we have stored some nodes and corresponding function values which we can load.
% 

load(fullfile(mtexDataPath, 'vector3d', 'smiley.mat'));

%%
% Note that if you don't have the the nodes and function values stored convieniently in a Matlab-file, you can alway use the <vector3d.load |load|> function of the class <vector3d.vector3d |vector3d|>.
% Next, we can make a scatter plot to see, what we a dealing with.
%

scatter(nodes, f, 'upper');

%%
% Now, we want to find a function which coincides with the given function values in the nodes reasonably well.

%% Interpolation
%
%%
% The idea of the first approach is fairly simple.
% We create a function which has *exaclty* the value of the given data in the nodes.
% But we still have to decide what happens inbetween these nodes.
% For that, we linearly interpolate between them, similarly as Matlat plots a one-dimensional function

plot(rand(10,1), '.-')

%%
% With some mathematics we can lift this concept to the sphere.
% This is done by the <vector3d.interp |interp|> command of the class <vector3d.vector3d |vector3d|> when the argument |'linear'| is given
%

sFTri = interp(nodes, f, 'linear');

%%
% To see that we realy have the exact function values, we can evaluate |sFTri| of type <S2FunTri.S2FunTri |S2FunTri|> and compare it with the original data values.

norm(eval(sFTri, nodes)-f)

%%
% Indeed, the error is within machine precision.
% Now we can work with the function defined on the whole sphere.
% We can, for instance, plot it

contourf(sFTri, 'upper');

%%
% That does not look like the happy smiley face we had in mind.
% There are other variants to fill the gaps between the data nodes, still preserving the interpolation property, which may improve the result.
% But if we don't restrict ourselfs to the given function values in the nodes, we have more freedom, which can be seen in the case of approximation.

%% Approximation
%
%%
% In contrast to interpolation we are now not restricted to the function values in the nodes but still want to keep the error reasonably small.
% One way to achieve this is to approximate it with a series of spherical harmonics.
% We don't take as many spherical harmonics as there are nodes, such that we are in the overdetermined case.
% In that way we don't have a chance of getting the error in the nodes zero but hope for a smoother approximation.
% This can be achieved by the <vector3d.interp |interp|> command of the class <vector3d.vector3d |vector3d|> when the argument |'harmnicApproximation'|

sF = interp(nodes, f, 'harmonicApproximation');
contourf(sF, 'upper');

%%
% Plotting this function, we can immidiately see, that we have a much smoother function.
% But one has to keep in mind that the error in the data nodes is not zero as in the case of interpolation.

norm(eval(sF, nodes)-f)

%%
% But this may not be of great importance like in the case of function approximation from noisy function values, where we don't know the exact function values anyways.

