%% Dislocations
% 
%%
% Dislocation are microscopic displacements within the regular atom lattice
% of a crystalline material usually as a result of plastic deformation.
% Dislocations are described by a Burgers vector describing the direction
% of the atomic shift and a line vector describing the direction of the
% displacements within the material. One distinguishes two cases:
%
%% Edge Dislocations
% Here the directions of the atomic shifts are orthogonal to the direction
% the displacements spread within the material. In order to define a edge
% dislocation we proceed as follows

% define a crystal symmetry
cs = crystalSymmetry('432');

% define a burgers vector in crystal coordinates
b = Miller(1,1,0,cs,'uvw')

% define a line vector in crystal coordinates
l = Miller(1,-1,-2,cs,'uvw')

% setup the dislocation system
dS = dislocationSystem(b,l)

%%
% The grey arrow is the line vector, the direction the dislocation runs
% along, and the red arrow is the Burgers vector, the shift the lattice
% suffers across it. For an edge dislocation the two are at right angles.

arrow3d(1.3*normalize(vector3d(l)),'faceColor',[.45 .45 .45])
hold on
arrow3d(0.9*normalize(vector3d(b)),'faceColor','red')
hold off
axis off

%% Screw Dislocations
% Screw dislocations are characterized by the fact that Burgers vector and
% line vector are parallel to each other.

% define a burgers vector in crystal coordinates
b = Miller(1,1,0,cs,'uvw')

% define a line vector in crystal coordinates
l = Miller(1,1,0,cs,'uvw')

% setup the dislocation system
dS = dislocationSystem(b,l)

%%
% The same two arrows, now lying on top of one another: for a screw
% dislocation the lattice is shifted along the direction the dislocation
% runs, so the Burgers vector and the line vector point the same way.

arrow3d(1.3*normalize(vector3d(l)),'faceColor',[.45 .45 .45])
hold on
arrow3d(0.9*normalize(vector3d(b)),'faceColor','red')
hold off
axis off


%% Relation to Slip Systems
% Dislocation systems are tightly related to <slipSystem.slipSystem.html
% slip systems>. Given a set of slip systems the corresponding edge and
% screw dislocations can be computed by

% dominant slip systems in cubic fcc material
sS = symmetrise(slipSystem.fcc(cs))

% the corresponding edge and screw dislocation
dS = dislocationSystem(sS)

%%
% A shortcut for the above lines is

dS = dislocationSystem.bcc(cs)


%% The Dislocation Tensor
% As each dislocation corresponds to an deformation of the atom lattice a
% dislocation can also be described by a deformation matrix. This matrix is
% the dyadic product between the Burgers vector and the line vector and can
% be computed by

dS.tensor

%%
% Note that the unit of this tensors is the same as the unit used for
% describing the length of the unit cell, which is in most cases Angstrom
% (au). For amount of deformation the norm of the Burgers vectors is
% important

% size of the unit cell
a = norm(cs.aAxis);

% in bcc and fcc the norm of the burgers vector is sqrt(3)/2 * a
[norm(dS(1).b), norm(dS(end).b), sqrt(3)/2 * a]


%% The Energy of Dislocations
% The energy of each dislocation system can be stored in the property |u|.
% By default this value it set to 1 but should be changed according to the
% specific model and the specific material.
%
% According to Hull & Bacon the energy U of edge and screw dislocations is
% given by the formulae
%
% $$ U_{\mathrm{screw}} = \frac{Gb^2}{4\pi} \ln \frac{R}{r_0} $$
%
% $$ U_{\mathrm{edge}} = \frac{1}{(1-\nu)} U_{\mathrm{screw}} $$
%
% where
%
% * |G| is the shear modulus
% * |b| is the length of the Burgers vector
% * |nu| is the Poisson ratio
% * |R| is the outer cut off radius
% * |r_0| is the radius of the dislocation core
%
% In this example we assume
% $$ U_{\mathrm{edge}} = 1 $$
% $$ U_{\mathrm{screw}} = 1-\nu $$

nu = 0.3;

% energy of the edge dislocations
dS(dS.isEdge).u = 1;

% energy of the screw dislocations
dS(dS.isScrew).u = 1 - nu;

%%
% There is no single accepted way of setting these energies. Formulae in use
% include |U = 1 - nu| as above, and |U = c * G * |b|^2| with |G| the shear
% modulus, i.e. an energy per unit length squared. Which one is appropriate
% depends on the model you are comparing against, so |u| is left for you to
% set rather than being fixed by MTEX.

%#ok<*NASGU>