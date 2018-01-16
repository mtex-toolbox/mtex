%%
% *Defning a S2VectorFieldHarmonic*
%
%%
% Definition via function values
%

nodes = equispacedS2Grid('points', 1e5); nodes = nodes(:); % get some interpolation nodes
f = @(v) vector3d('polar', sin(3*v.theta), v.rho+pi/2);
y = f(nodes); % example function values
sVF1 = S2VectorFieldHarmonic.approximation(nodes, y)


%%
% Definition via function handle
%

f = @(v) vector3d(v.x, v.y, 0*v.x);
sVF2 = S2VectorFieldHarmonic.quadrature(@(v) f(v), 'bandwidth', 50) % default bandwidth is 128


%%
% *Visualization*
%

plot(sVF1); % same as quiver(sVF1)
snapnow;
clf;
quiver3(sVF2);
snapnow;

%%
% *Operations*
%
%%
% *Basic operations*
%


% addition/subtraction
sVF1+sVF2; sVF1+vector3d(1, 0, 0);
sVF1-sVF2; sVF2-vector3d(sqrt(2)/2, sqrt(2)/2, 0);

% multiplication/division
2.*sVF1; sVF1./4;

% dot product
dot(sVF1, sVF2); dot(sVF1, vector3d(0, 0, 1));

% cross product

cross(sVF1, sVF2); cross(sVF1, vector3d(0, 0, 1));


%%
% *other operations*
%

%%
% mean value
%

mean(sVF1)

%%
% Rotation
%

r = rotation('Euler', [pi/4 0 0]);
rotate(sVF1, r);

%%
% pointwise norm of the vectors
%

norm(sVF1);