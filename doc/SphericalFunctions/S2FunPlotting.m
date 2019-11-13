%% Plotting Spherical Functions
%
%%
% In this chapter various ways of plotting spherical functions are
% explained. We start by defining some example functions.

% the smiley
sF1 = S2Fun.smiley;

% some osilatory function
f = @(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y));
sF2 = S2FunHarmonic.quadrature(f, 'bandwidth', 150);

%% Smooth Plot
% The default <S2Fun.plot.html |plot|> command generates a colored plot
% without contours

plot(sF1)

%%
% * |plot(sF1)| is the same as |pcolor(sF1)|

%% Contour Plot
% nonfilled contour plot plots only the contour lines
contour(sF1, 'LineWidth', 2);

%% Filled Contour Plot
% filled contour plot plots the contour lines
contourf(sF1, 'LineWidth', 2);

%% 3D Plot
% 3D plot of a sphere colored accordingly to the function values.
plot3d(sF1);

%% Surface Plot
% 3D plot where the radius of the sphere is transformed according to the function values
surf(sF2);

%% Section Plot
% Plot the intersection of the surf plot with a plane defined by a normal vector |v|

plotSection(sF2, zvector,'color','interp','linewidth',10)
colormap spring
mtexTitle('Flowerpower!')

%% Spectral Plot
% plotting the Fourier coefficients

close all
plotSpektra(sF1,'FontSize',15);

%%
% The more specific plot options are covered in the respective classes.
