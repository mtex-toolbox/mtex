%% Plotting Spherical Functions
%
% In this chapter various ways of plotting spherical functions are
% explained.
%
%%
% Here ew first define some example functions.
%

sF1 = S2Fun.smiley;

f = @(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y));
sF2 = S2FunHarmonic.quadrature(f, 'bandwidth', 150)

%% Smooth Plot
% The default |plot|-command is a colored plot without contours
plot(sF1); 

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
plot3d(sF2);

%% Surface Plot
% 3D plot where the radius of the sphere is transformed according to the function values
surf(sF2);

%% Section Plot
% Plot the intersection of the surf plot with a plane defined by a normal vector |v|
plotSection(sF2, zvector);

%% Spectral Plot
% plotting the Fourier coefficients
plotSpektra(sF1);
set(gca,'FontSize', 20);

%%
% The more specific plot options are covered in the respective classes.
