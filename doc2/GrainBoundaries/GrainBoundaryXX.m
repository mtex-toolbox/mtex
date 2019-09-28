%% Grain smoothing
% The reconstructed grains show the typical staircase effect. This effect
% can be reduced by smoothing the grains. This is particulary important
% when working with the direction of the boundary segments

% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,angle(grains.boundary.direction,xvector)./degree,'linewidth',3.5)
mtexColorbar

% stop overide mode
hold off

%%
% We see that the angle between the grain boundary direction and the x-axis
% takes only values 0, 45 and 90 degrees. After applying smoothing we obtain
% a much better result

% smooth the grain boundaries
grains = smooth(grains)

% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,angle(grains.boundary.direction,xvector)./degree,'linewidth',3.5)
mtexColorbar

% stop overide mode
hold offs