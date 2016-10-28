%% Discretisation of 2 - Sphere (The Class @S2Grid)
% represents a grid of nodes on the sphere 
%
%% Contents
%
%% Class Description
% The class *S2Grid* is used in MTEX to store the set of specimen
% directions organized in a [[PoleFigure_index.html,pole figure]]. Of 
% central importance is also the plotting method of this class since it is 
% used by almost all other plotting methods in MTEX to perform spherical 
% plots. 
%
%% SUB: Defining a S2Grid
%
% There are various ways to define a S2Grid. Next, you find some examples.
% For a detailed description of possible specifications look for the
% documentation of the constructor [[S2Grid_index.html,S2Grid]]. 

% equidistributions
S2G = equispacedS2Grid('points',100,'antipodal');  % specified by number of points
S2G = equispacedS2Grid('RESOLUTION',5*degree,'antipodal');  % specified by resolution

% regular grids
S2G = regularS2Grid('points',[72,19]); % specified by number of theta and rho steps
S2G = regularS2Grid('theta',linspace(0,2*pi,72),...
             'rho',linspace(0,pi/2,19)); % explicitly determine theta and rho values

% restrictes grids
S2G = equispacedS2Grid('points',100,'MAXTHETA',75*degree);  % specify maximum theta angle

%% SUB: Plots

plot(equispacedS2Grid('points',100,'antipodal'))  % plot the grid of nodes

