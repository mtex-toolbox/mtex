%% Sigle Slip Model
%
% Details to this model can be found in
%
% * <https://doi.org/10.1093/gji/ggy442 An analytical finite-strain
% parametrization for texture evolution in deforming olivine polycrystals>,
% Geoph. J. Intern. 216, 2019.
%
%% The Continuity Equation
%
% The evolution of the orientation distribution function (ODF) $f(g)$ with
% respect to a crystallopgraphic spin $\Omega(g)$ is governed by the
% continuity equation
% 
% $$\frac{\partial}{\partial t} f + \nabla f \cdot \Omega + f \text{ div } \Omega = 0$$
% 
% The solution of this equation depends on the initial texture $f_0(g)$ at
% time zero and the crystallographic spin $\Omega(g)$. In this model we
% assume the initial texture to be isotrope, i.e., $f_0 = 1$ and the
% crystallopgraphic spin be associated with a single slip system. The full
% ODF will be later modelled as a superposition of the single slip models.
%
%% 
% In this example we consider Olivine with has orthorhombic symmetry

csOli = crystalSymmetry('222',[4.779 10.277 5.995],'mineral','olivine');
csOrtho = crystalSymmetry('222',[18.384, 8.878, 5.226],'mineral','orthopyroxene');

%%
% and the basic slip systems in olivine and orthopyroxene

sSOli = slipSystem(Miller({1,0,0},{1,0,0},{0,0,1},csOli,'uvw'),...
  Miller({0,1,0},{0,0,1},{0,1,0},csOli,'hkl'))

sSOrtho = slipSystem(Miller({0,0,1},csOrtho,'uvw'),...
  Miller({1,0,0},csOrtho,'hkl'))

%%
% To each of the slip systems we can associate an orientation dependent
% Schmid or deformation tensor $S(g)$

S = sSOli.deformationTensor

%%
% and make for the orientation dependent strain rate tensor $e(g)$ the
% ansatz $e_{ij}(g) = \gamma(g) S_{ij}(g)$. Fitting this ansatz to a given
% a macroscopic strain tensor

E = strainRateTensor([1 0 0; 0 0 0; 0 0 -1])

%%
% via minimizing the square difference
% 
% $$\int_{SO(3)} \sum_{i,j} (e_{i,j}(g) - E_{i,j})^2 dg \to \text{min}$$
% 
% the orientation dependent strain rate tensor is identified as
%
% $$e(g) = 2 \left< S(g), E \right> S(g)$$
%
% and the corresponding crystallographic spin tensor as
%
% $$\Omega_i(g) = \epsilon_{ijk} e_{jk}(g)$$
%
% This can be modeled in MTEX via

Omega1 = @(ori) vector3d(spinTensor(((ori * S(1)) : E) .* (ori * S(1))));
Omega1 = SO3VectorFieldHarmonic.quadrature(Omega1,csOli)

% other versions
% Omega = @(ori) 0.5 * EinsteinSum(tensor.leviCivita,[1 -1 -2],(ori * S(1) : E) * (ori * S(1)),[-1 -2])
% Omega2 = @(ori) vector3d(spinTensor(((ori * S(1)) : E) .* S(1)));
% Omega2 = SO3VectorFieldHarmonic.quadrature(Omega2,csOli)

%%
% We may visualize the orientation depedence of the spin tensor via

plot(Omega1)

%%

%plot(dot(Omega1,zvector))

%%
% or the divergence of this vectorfield 
plot(div(SO3VectorFieldHarmonic(Omega2)))

%% Solutions of the Continuity Equation
% The solutions of the continuity equation can be analytically computed and
% are available via the command <SO3FunSBF.SO3FunSBF.html |SO3FunSBF|>.
% This command takes as input the specific slips system |sS| and the
% makroscopic strain tensor |E|

odf1 = SO3FunSBF(sSOli(1),E)
odf2 = SO3FunSBF(sSOli(2),E)
odf3 = SO3FunSBF(sSOli(3),E)
odf4 = SO3FunSBF(sSOrtho,E)

%%
% Lets visualize these solution by their pole figures

h = Miller({1,0,0},{0,1,0},{0,0,1},csOli);
plotPDF(odf1,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%%

plotPDF(odf2,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%%

plotPDF(odf3,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%% 
% We observe that the pole figure with respect to $n \times b$ is always
% uniform, where $n$ is the slip normal and $b$ is the slip direction.

%%
% 

plotPDF(odf1 + odf2 + odf3,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%% Checking the Continuity Equation
% We may now check wether the continuity equation is satisfied. In a stable
% state the time difference will be zero and hence $\text{div}(f  \Omega) =
% 0$
%
% TODO: this is currently not working!

plot(div(SO3VectorFieldHarmonic(Omega .* odf1)))
mtexColorbar('location','south')

%%

plot(div(SO3VectorFieldHarmonic(odf1 .* Omega1)),'sigma')

%%

plot(dot(Omega1,grad(odf1)))
