%% Tensor Visualization
%
%%
% A tensor of rank two or higher has too many components to be read off a
% list. What can be looked at instead is its *directional magnitude* - the
% scalar that the tensor produces when it is contracted with one and the
% same direction in all of its slots. For a tensor $T$ of rank $r$ this is
%
% $$ Q(\vec x) = T_{i_1 \ldots i_r}\, x_{i_1} \cdots x_{i_r}, \qquad |\vec x| = 1, $$
%
% a function on the sphere, i.e. an <S2FunConcept.html S2Fun>, and plotting
% it is what the |plot| command of a tensor does by default.

setMTEXpref('defaultColorMap',blue2redColorMap);

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivine');
C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs)

%%

plot(C,'complete','upper')
text(Miller({1,0,0},{0,1,0},{0,0,1},cs,'uvw'),'labeled','backgroundColor','White')

%%
% set back the default color map.

setMTEXpref('defaultColorMap',WhiteJetColorMap)

%% The directional magnitude is a spherical function
%
% Since the directional magnitude is an ordinary spherical function, all of
% the <S2FunPlotting.html spherical plotting options> apply - filled
% contours, contour lines, 3d plots, and any
% <SphericalProjections.html spherical projection>.

plot(C,'contourf','upper')
mtexColorbar

%%

plot(C,'3d')

%%
% It can also be obtained as an object in its own right, which is useful
% whenever one wants to compute with it rather than only look at it - find
% its extrema, integrate it, or compare two tensors.

sF = C.directionalMagnitude

%%

[v,pos] = max(sF)

%% Rank two tensors and their principal axes
%
% For a symmetric rank two tensor the directional magnitude is the
% quadratic form $\vec x^T T \vec x$, and its extrema are attained along
% the eigenvectors. Hence the plot shows the principal axes directly.

T = tensor(diag([3 1 -1]),'rank',2)

%%

plot(T,'complete','upper')
mtexColorbar

%%

[e,lambda] = eig(T);

hold on
plot(e,'plane','linewidth',2,'antipodal')
hold off

%% Sections
%
% Some derived quantities are not functions of a single direction. The
% Poisson ratio and the shear modulus, for instance, depend on two
% directions, and it is only meaningful to evaluate them for directions
% perpendicular to the first one. Such functions are best drawn as a
% <S2Fun.plotSection.html section> along the corresponding great circle -
% see <AnisotropicTheory.html the elasticity chapter>.

p = vector3d.Z;

plotSection(C.PoissonRatio(p),p,'color','interp','linewidth',5)
axis off
mtexColorbar

%% Specialized plots
%
% Beyond the directional magnitude there are visualizations that only make
% sense for one particular kind of tensor - wave velocities and their
% polarizations for the <WaveVelocities.html elasticity tensor>, the
% <BirefringenceDemo.html birefringence> of the refractive index tensor, or
% the <PiezoElectricity.html piezoelectric> modulus. Each is described in
% its own chapter.

%#ok<*NOPTS,*ASGLU>
