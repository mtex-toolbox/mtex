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

mtexColorbar

%%
% In particular, all of the <S2FunPlotting.html spherical plotting options>
% apply - filled contours, contour lines, 3d plots, as well as any
% <SphericalProjections.html spherical projection>.
%
% Furthermore, we can access this directional function directly by

sF = C.directionalMagnitude

%%
% and use it to derive e.g. the location of the maximum directional
% magnitude

[v,pos] = max(sF)


%% Rank two tensors and their principal axes
%
% For a symmetric rank two tensor the directional magnitude is the
% quadratic form $\vec x^T T \vec x$, and its extrema are attained along
% the eigenvectors. Hence the plot shows the principal axes directly.

T = tensor(diag([3 1 -1]),'rank',2,plottingConvention('y↑→x'))

%%

plot(T,'complete','upper')
mtexColorbar

%%
% the principle axes of a symmetric rank two tensor are computed by the
% command <tensor.eig.html |eig|>

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
%%

setMTEXpref('defaultColorMap',WhiteJetColorMap)

%%
%#ok<*NOPTS,*ASGLU>
