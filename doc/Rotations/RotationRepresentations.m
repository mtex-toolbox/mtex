%% Rotation Representations
%
%%
% Internally MTEX stores every <rotation.rotation.html |rotation|> as a
% <quaternion.quaternion.html |quaternion|>, i.e., by four numbers. For many
% purposes it is more convenient to describe a rotation by a single three
% dimensional vector. All representations discussed here follow the same
% recipe: take the rotational axis $\vec n$ and scale it by some function
% $f(\omega)$ of the rotational angle $\omega$,
%
% $$ \vec v = f(\omega) \, \vec n. $$
%
% What distinguishes them is the choice of $f$ - and that choice decides
% which region of $\mathbb R^3$ the rotations fill, and whether the mapping
% preserves volume. Let us start with a large set of uniformly distributed
% random rotations.

rot = rotation.rand(100000)

%% The Rodrigues Vector
%
% The Rodrigues vector uses $f(\omega) = \tan(\omega/2)$, so that
%
% $$ \vec v = \tan\frac{\omega}{2} \, \vec n. $$
%
% It is computed by <quaternion.Rodrigues.html |Rodrigues|> and inverted by
% <rotation.byRodrigues.html |rotation.byRodrigues|>.

vRodrigues = rot.Rodrigues;

%%
% Its defining property is that rotations sharing a common axis lie on a
% straight line through the origin. The price is that the representation is
% *unbounded*: as $\omega$ approaches $180^\circ$ the tangent diverges, so a
% half turn has no finite Rodrigues vector at all.

max(norm(vRodrigues))

%%
% This is why plots in Rodrigues space are usually restricted to a
% fundamental region - see <RotationPlotting.html Plotting Rotations>.

%% The Homochoric Vector
%
% The homochoric vector uses
%
% $$ f(\omega) = \left(\frac{3}{4}\left(\omega - \sin\omega\right)\right)^{1/3} $$
%
% and is computed by <quaternion.homochoric.html |homochoric|>, with
% <rotation.byHomochoric.html |rotation.byHomochoric|> as its inverse.

vHomochoric = rot.homochoric;

%%
% This choice makes the mapping *equal volume*: it takes the rotation group
% onto a ball and does not distort densities. The ball has radius
% $(3\pi/4)^{1/3}$, reached exactly by the half turns.

max(norm(vHomochoric))
(0.75*pi)^(1/3)

%%
% Equal volume means that uniformly distributed rotations become uniformly
% distributed points in that ball. For a uniform ball the distribution of the
% radius $r$ has the density $3r^2/R^3$, which is exactly what we observe.

R = (0.75*pi)^(1/3);
histogram(norm(vHomochoric),50,'Normalization','pdf')
hold on
r = linspace(0,R,100);
plot(r,3*r.^2/R^3,'linewidth',2)
hold off
legend('homochoric radii','3r^2/R^3')
xlabel('r')

%%
% The same check applied to the Rodrigues vectors shows the contrast - the
% density there is strongly concentrated near the origin and has an infinite
% tail.

histogram(min(norm(vRodrigues),10),50,'Normalization','pdf')
xlabel('|v|, clipped at 10')

%% The Cubochoric Vector
%
% The cubochoric vector, introduced by
% <http://dx.doi.org/10.1088/0965-0393/22/7/075013 Rosca, Morawiec and De
% Graef (2014)>, composes the homochoric map with an equal volume map from
% the ball onto a cube. It is computed by
% <quaternion.cubochoric.html |cubochoric|>.

vCubochoric = rot.cubochoric;

%%
% The resulting cube has edge length $\pi^{2/3}$.

max(abs(vCubochoric.x))
pi^(2/3)/2

%%
% Being equal volume as well, it shares the density preserving property of
% the homochoric vector, but on a cube rather than a ball. That makes it the
% natural choice for building uniform grids in orientation space, which is
% what <homochoricSO3Grid.homochoricSO3Grid.html |homochoricSO3Grid|> does.
%
% There is no |rotation.byCubochoric|. The inverse is obtained by first
% mapping the cube back onto the ball with <cubo2homo.html |cubo2homo|>.

xyz = cubo2homo([vCubochoric.x(:), vCubochoric.y(:), vCubochoric.z(:)]);
rot2 = rotation.byHomochoric(xyz);

% the reconstruction error, measured as quaternion distance
max(min(norm(rot(:)-rot2),norm(rot(:)+rot2)))

%% Summary
%
% || *representation* || $f(\omega)$ || *region* || *equal volume* ||
% || <quaternion.Rodrigues.html Rodrigues> || $\tan(\omega/2)$ || all of $\mathbb R^3$, unbounded || no ||
% || <quaternion.homochoric.html homochoric> || $\left(\frac34(\omega-\sin\omega)\right)^{1/3}$ || ball of radius $(3\pi/4)^{1/3}$ || yes ||
% || <quaternion.cubochoric.html cubochoric> || - || cube of edge $\pi^{2/3}$ || yes ||
%
% Note that none of these is what MTEX uses to *store* a rotation. They are
% derived on demand, and the axis angle parametrisation they all build on is
% available directly as <quaternion.axis.html |axis|> and
% <quaternion.angle.html |angle|>.

angle(rot(1))./degree
axis(rot(1))

%#ok<*NOPTS>
