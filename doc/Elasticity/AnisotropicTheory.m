%% Anisotropic Elasticity
%
%%
% An anisotropic material responds differently when the loading direction
% changes. A single elastic modulus can therefore describe only one loading
% geometry.
%
% The fourth-order stiffness tensor $C$ collects the complete linear elastic
% response. MTEX represents it as a
% <stiffnessTensor.stiffnessTensor.html |stiffnessTensor|>.
% This page loads one measured tensor, applies Hooke's law, and then queries
% its response for chosen directions and planes.

plottingConvention.default('y↑→x');

%% Load the olivine stiffness tensor
%
% A stiffness tensor can be constructed from a symmetric 6-by-6 matrix.
% It can also be imported from a file, as in this example.
% The data are the olivine measurements of Abramson et al. (1997).

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

% orthorhombic crystal symmetry and crystal frame
cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],...
  'mineral','Olivine');

% stiffness tensor in GPa
C = stiffnessTensor.load(fname,cs)

%%
% A general anisotropic stiffness has as many as 21 independent numbers.
% The orthorhombic symmetry of olivine reduces this matrix to nine.
% The zero entries in the displayed matrix are imposed by that symmetry.
% The two-number isotropic limit was developed in
% <IsotropicTheory.html Isotropic Theory>.

%% Apply Hooke's law
%
% Stress is force per unit area, including its direction on each plane.
% Strain records the corresponding fractional change of shape.
% Linear elasticity maps a given strain to stress with $C$.
%
% Start with a diagonal strain tensor.

eps = strainTensor(diag([1,1.1,0.9]),cs)

%%
% Hooke's law is the double contraction of stiffness and strain.

sigma = C : eps

%%
% The compliance tensor $S=C^{-1}$ performs the reverse mapping.
% Applying it to the stress recovers the original strain.

S = inv(C);
eps_recovered = S : sigma

%% Compute the elastic energy
%
% The elastic energy of this strain can be computed in three equivalent
% ways. The first contracts the stress with the strain.

U_contraction = sigma : eps

%%
% The second writes every contraction index explicitly.

U_Einstein = EinsteinSum(C,[-1 -2 -3 -4],...
  eps,[-1 -2],eps,[-3 -4])

%%
% The third applies Hooke's law first and then contracts with the strain.

U_Hooke = (C : eps) : eps

%% Young's modulus by loading direction
%
% <IsotropicTheory.html Isotropic Theory> defines Young's modulus as the
% ratio of axial stress to axial strain.
% In an anisotropic crystal it depends on the loading direction $d$.
% Passing one direction to
% <stiffnessTensor.YoungsModulus.html |YoungsModulus|> returns one value.

d = vector3d.X;
E_x = C.YoungsModulus(d)

%%
% Omitting $d$ returns the complete directional dependence as an
% <S2FunHarmonic.S2FunHarmonic.html |S2FunHarmonic|>.

E = C.YoungsModulus

% evaluate the same spherical function along x
E.eval(d)

% plot every loading direction
newMtexFigure
plot(E,'complete','upper')
mtexColorMap blue2red
mtexColorbar('title','Young''s modulus in GPa')

%%
% Each point on the hemisphere is a possible loading direction.
% The changing colours and non-circular contours show why one Young's
% modulus cannot describe this crystal.

%% Linear compressibility by direction
%
% Linear compressibility is the fractional length change along a direction
% caused by an increase in hydrostatic pressure.
% Contracting the compliance tensor with the pressure gives a second-rank
% tensor, whose directional values form another spherical function.
%
% <stiffnessTensor.linearCompressibility.html |linearCompressibility|>
% returns that function when the direction is omitted.

beta = linearCompressibility(C)

newMtexFigure
plot(beta,'complete','upper')
mtexColorMap blue2red
mtexColorbar('title','linear compressibility in 1/GPa')

%%
% The map answers a different question from Young's modulus.
% It shows the length response to pressure applied from every direction,
% rather than the axial response to one uniaxial load.
%
% Evaluate the function along the same $x$ direction.

beta_x = beta.eval(d)

%% Poisson's ratio around a pulling direction
%
% <IsotropicTheory.html Isotropic Theory> defines Poisson's ratio from the
% axial and transverse strains.
% An anisotropic value needs a pulling direction $p$ and a transverse
% direction $n$ perpendicular to it.

% pulling direction
p = vector3d.Z;

% two transverse directions
n = [vector3d.X,vector3d.Y];

% one value for each transverse direction
nu_xy = C.PoissonRatio(p,n)

%%
% Omitting $n$ from <stiffnessTensor.PoissonRatio.html |PoissonRatio|>
% leaves a spherical function of possible transverse directions.

nu = C.PoissonRatio(p)

%%
% Only directions perpendicular to $p$ are physically meaningful.
% A <S2Fun.plotSection.html section plot> restricts the function to that
% plane, which is the $xy$ plane for the chosen $z$ pulling direction.

newMtexFigure
plotSection(nu,p,'color','interp','linewidth',5)
axis off
mtexColorMap blue2red
mtexColorbar('title','Poisson''s ratio')

%%
% Read around the circle rather than across its interior.
% The colour change around the circle shows that transverse contraction
% depends on which perpendicular direction is observed.

%% Shear modulus for a plane and direction
%
% <IsotropicTheory.html Isotropic Theory> defines the shear modulus as the
% ratio of shear stress to shear strain.
% An anisotropic value needs the normal $h$ of the shear plane and a shear
% direction $u$ within that plane.
%
% Passing both directions to
% <stiffnessTensor.shearModulus.html |shearModulus|> returns one number.

% unit shear-plane normal
h = Miller(0,0,1,cs).normalize;

% unit shear direction within that plane
u = Miller(1,0,0,cs,'uvw').normalize;

G = C.shearModulus(h,u)

%%
% Omitting the shear direction leaves a spherical function of $u$.
% Only directions within the shear plane are meaningful.
% Plot a section for each of three different plane normals.

newMtexFigure('layout',[1,3])

hMiller = Miller(1,0,0,cs);
h = hMiller.normalize;
plotSection(C.shearModulus(h),h,'color','interp','linewidth',5)
mtexTitle(char(hMiller))
axis off

nextAxis
hMiller = Miller(1,1,0,cs);
h = hMiller.normalize;
plotSection(C.shearModulus(h),h,'color','interp','linewidth',5)
mtexTitle(char(hMiller))
axis off

nextAxis
hMiller = Miller(1,1,1,cs);
h = hMiller.normalize;
plotSection(C.shearModulus(h),h,'color','interp','linewidth',5)
mtexTitle(char(hMiller))
axis off

setColorRange('equal')
mtexColorMap blue2red
mtexColorbar('title','shear modulus in GPa')
drawNow(gcm,'figSize','large')

%%
% The common colour range makes the three sections directly comparable.
% Both the colour variation within a circle and the differences between
% circles belong to the anisotropic shear response.

%% The maths behind the shear modulus
%
% Write the compliance tensor as $S=C^{-1}$.
% For a unit plane normal $h$ and a perpendicular unit direction $u$, the
% directional shear modulus is
%
% $$G(h,u)=\frac{1}{4\,S_{ijkl}\,h_i u_j h_k u_l}.$$
%
% Fixing $h$ while varying $u$ gives the section plots above.
% Passing both directions evaluates the same expression as a number.

%#ok<*BDSCI>
%#ok<*NASGU>
%#ok<*BDSCA>

%% References
%
% * E. H. Abramson, J. M. Brown, L. J. Slutsky, and J. Zaug,
% <https://doi.org/10.1029/97JB00682 The elastic constants of San Carlos
% olivine to 17 GPa>, _Journal of Geophysical Research_ 102(B6) (1997),
% 12253-12263, provides the olivine stiffness tensor used here.
% * J. F. Nye, <https://search.worldcat.org/title/11114089 Physical
% Properties of Crystals: Their Representation by Tensors and Matrices>,
% Oxford University Press, 1985, develops the symmetry constraints and
% tensor contractions used for anisotropic physical properties.

%% Next
%
% <WaveVelocities.html Wave Velocities> combines this stiffness tensor with
% density. It solves for the three wave speeds and their polarisation
% directions for every propagation direction.
