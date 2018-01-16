%%
% *Defning a S2FunHarmonic*
%
%%
% Definition via function values
%

nodes = equispacedS2Grid('points', 1e5); nodes = nodes(:); % get some interpolation nodes
y = smiley(nodes); % example function values
sF1 = interp(nodes, y, 'harmonicApproximation') % same as S2FunHarmonic.approximation(nodes, y)


%%
% Definition via function handle
%

sF2 = S2FunHarmonic.quadrature(@(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y)), 'bandwidth', 50) % default bandwidth is 128


%%
% *Visualization*
%

plot(sF1); % same as contourf(sF1)
snapnow;
contour(sF1, 'LineWidth', 2);
snapnow;
pcolor(sF1);
snapnow;
plot3d(sF2);
snapnow;
surf(sF2);
snapnow;
v = zvector;
plotSection(sF2, v.Z);
snapnow;

%%
% plotting the fourier coefficients
%

plotSpektra(sF1);
set(gca,'FontSize', 20);
snapnow;

%%
% *Operations*
%
%%
% *Basic arithmecic operations*
%

% absolute value of a function
abs(sF1);

% addition/subtraction
sF1+sF2; sF1+2;
sF1-sF2; sF2-4;

% multiplication/division
sF1.*sF2; 2.*sF1;
sF1./(sF2+1); 2./sF2; sF2./4;

% power
sF1.^sF2; 2.^sF1; sF2.^4;

%%
% *min/max*
%
%%
% min/max of a single function
%

[maxvalue, maxnodes] = max(sF1);
[minvalue, minnodes] = min(sF1); % same as steepestDescent(sF1)
maxvalue, minvalue
plot3d(sF1);
hold on;
scatter3d(maxnodes, 'MarkerColor', 'k', 'MarkerSize', 10);
scatter3d(minnodes, 'MarkerColor', 'b', 'MarkerSize', 10);
hold off;
snapnow;

%%
% min/max of two functions in the pointwise sense
%

min(sF1, sF2);


%%
% *other operations*
%

%%
% $L^2$-norm
%

norm(sF1)

%%
% mean value
%

mean(sF1)

%%
% Rotation
%

r = rotation('Euler', [pi/4 0 0]);
rotate(sF1, r);

%%
% *gradient*
%

plot(sF1);
hold on;
G = grad(sF1)
plot(G);

%%
% symmetrization
%

cs = crystalSymmetry('6/m');
sFs = symmetrise(sF1, cs)