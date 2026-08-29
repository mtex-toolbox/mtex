%% Dislocation Systems
%
% Plastic deformation in a crystal is carried by dislocations moving through
% its regular atomic lattice. A *dislocation* is a line defect rather than a
% microscopic displacement by itself.
%
% Two vectors describe its geometry. The Burgers vector $\mathbf b$ gives the
% lattice translation accumulated around the defect. The line vector
% $\mathbf l$ gives the direction of the defect line.
%
% MTEX represents a pure edge or screw geometry with a
% <dislocationSystem.dislocationSystem.html |dislocationSystem|>. This page
% constructs both types and then prepares the systems used to estimate
% geometrically necessary dislocations from an EBSD map.

%% Edge dislocations
% In a pure edge dislocation, the Burgers vector is perpendicular to the line
% vector. Start with a cubic crystal frame and two crystal directions.

cs = crystalSymmetry('432');
bEdge = Miller(1,1,0,cs,'uvw')
lEdge = Miller(1,-1,-2,cs,'uvw')

%%
% The constructor checks that the two vectors are perpendicular or parallel.
% A general mixed dislocation cannot be entered with this constructor.

dSEdge = dislocationSystem(bEdge,lEdge)

%%
% The grey arrow is the line vector, along which the defect runs. The red
% arrow is the Burgers vector, which gives the lattice shift across it.

arrow3d(1.3*normalize(vector3d(lEdge)), ...
  'faceColor',[0.45 0.45 0.45])
hold on
arrow3d(0.9*normalize(vector3d(bEdge)),'faceColor','red')
hold off
axis off

%%
% Notice that the two arrows meet at a right angle. This orthogonality is the
% defining geometric feature of the edge system.

%% Screw dislocations
% In a pure screw dislocation, the Burgers vector and line vector are
% parallel. The same Burgers vector can therefore serve as both inputs.

bScrew = Miller(1,1,0,cs,'uvw')
lScrew = Miller(1,1,0,cs,'uvw')
dSScrew = dislocationSystem(bScrew,lScrew)

%%
% Draw the line vector longer so that both arrows remain visible when they
% lie on top of one another.

close all
arrow3d(1.3*normalize(vector3d(lScrew)), ...
  'faceColor',[0.45 0.45 0.45])
hold on
arrow3d(0.9*normalize(vector3d(bScrew)),'faceColor','red')
hold off
axis off

%%
% The coincident arrows show that the lattice shift is along the direction in
% which the defect runs. This parallelism distinguishes the screw system.

%% Build systems from slip systems
% A <SlipSystems.html slip system> supplies a Burgers vector and a slip-plane
% normal. MTEX converts each slip system into an edge system with a line
% direction in the slip plane, and also adds the distinct screw systems.
%
% Here the 12 geometrically distinct FCC slip systems produce 12 edge and 6
% screw systems. The |'antipodal'| option identifies opposite shear senses
% before the conversion.

sSFcc = symmetrise(slipSystem.fcc(cs),'antipodal');
dSFcc = dislocationSystem(sSFcc);
[sum(dSFcc.isEdge), sum(dSFcc.isScrew)]

%%
% The named constructor performs the corresponding conversion for the
% standard BCC family. It is a shortcut for constructing and symmetrising
% |slipSystem.bcc(cs)|, not for the FCC lines above.

dSBcc = dislocationSystem.bcc(cs);
[sum(dSBcc.isEdge), sum(dSBcc.isScrew)]

%%
% MTEX uses one half of the cubic slip direction as the Burgers vector during
% this conversion. It also uses one third of a hexagonal slip direction.
% Other lattices trigger a warning because the physical scale is ambiguous.

%% The dislocation tensor
% A dislocation system contributes the dyadic tensor
% $\mathbf b\otimes\hat{\mathbf l}$, where the hat denotes a unit line vector.
% This tensor is sometimes described informally as a deformation matrix.
% In MTEX it is a basis tensor for the dislocation-density tensor used on the
% next page.

dTBcc = dSBcc.tensor

%%
% The tensor has the same length unit as the unit-cell axes because the line
% vector is normalized. MTEX labels this unit |au|; for a lattice specified
% in Angstrom, its entries are therefore in Angstrom.
%
% The Burgers-vector norm sets the scale of each basis tensor. For the unit
% cubic cell used here, a BCC $\langle111\rangle/2$ Burgers vector has length
% $\sqrt{3}/2$.

a = norm(cs.aAxis);
[norm(dSBcc(1).b), norm(dSBcc(end).b), sqrt(3)/2 * a]

%%
% The earlier statement that both BCC and FCC Burgers vectors have length
% $\sqrt{3}a/2$ is not generally correct. An FCC
% $\langle110\rangle/2$ Burgers vector has length $a/\sqrt{2}$, as this check
% shows.

[norm(dSFcc(1).b), a/sqrt(2)]

%% Set relative line energies
% The property |u| stores the relative line energy used when MTEX chooses a
% non-negative combination of systems. A directly constructed system has
% |u = 1| by default. Conversion from slip systems currently initializes
% |u = 2| for edge systems and |u = 1| for screw systems.
%
% Hull and Bacon give the elastic line energies
%
% $$ U_{\mathrm{screw}} = \frac{G b^2}{4\pi}
%    \ln\left(\frac{R}{r_0}\right), $$
%
% $$ U_{\mathrm{edge}} = \frac{1}{1-\nu}
%    U_{\mathrm{screw}}, $$
%
% where $G$ is the shear modulus, $b$ is the Burgers-vector length, $\nu$ is
% Poisson's ratio, $R$ is the outer cut-off radius, and $r_0$ is the
% dislocation-core radius.
%
% If all systems share the other factors, one convenient normalization is
% $U_{\mathrm{edge}}=1$ and $U_{\mathrm{screw}}=1-\nu$.

nu = 0.3;
dSBcc(dSBcc.isEdge).u = 1;
dSBcc(dSBcc.isScrew).u = 1 - nu;

%%
% There is no single accepted way to set these weights. Another model may
% use |u = c * G * norm(b)^2|, with a model-dependent constant |c|.
% When $G$ is a shear modulus, this expression has units of energy per unit
% length; earlier wording on this page called it energy per length squared.
% Choose |u| for the material and model being compared rather than treating
% an MTEX default as a measured energy.

%#ok<*NASGU>

%% References
%
% * D. Hull and D. J. Bacon,
% <https://doi.org/10.1016/C2009-0-64358-0 Introduction to Dislocations>,
% fifth edition, Butterworth-Heinemann, 2011, derives the edge and screw line
% energies used to motivate the relative weights above.

%% Next
%
% Continue with <GND.html Geometrically Necessary Dislocations> to turn an
% EBSD orientation gradient into densities of the systems defined here.
