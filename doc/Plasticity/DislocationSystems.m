%% Dislocations
% 
%%
% Dislocation are microscopic displacements within the regular atom lattice
% of a crystaline material ussualy as a result of plastic deformation.
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


%% Screw Dislocations
% Screw dislocations are characterized by the fact that Burgers vector and
% line vector are perpendicular to each other.

% define a burgers vector in crystal coordinates
b = Miller(1,1,0,cs,'uvw')

% define a line vector in crystal coordinates
l = Miller(1,1,0,cs,'uvw')

% setup the dislocation system
dS = dislocationSystem(b,l)


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
% By default this value it set to 1 but should be changed accoring to the
% specific model and the specific material.
%
% According to Hull & Bacon the energy U of edge and screw dislocations is
% given by the formulae
%
% $$ U_{\mathrm{screw}} = \frac{Gb^2}{4\pi} \ln \frac{R}{r_0} $$
%
% $$ U_{\mathrm{edge}} = (1-\nu) U_{\mathrm{screw}} $$
%
% where
% 
% * |G| is 
% * |b| is the length of the Burgers vector
% * |nu| is the Poisson ratio
% * |R|
% * |r|
%
% In this example we assume 
% 
% R = 
% r_0 = 
% U = norm(dS.b).^2

nu = 0.3;

% energy of the edge dislocations
dS(dS.isEdge).u = 1;

% energy of the screw dislocations
dS(dS.isScrew).u = 1 - 0.3;

% Question to verybody: what is the best way to set the enegry? I found
% different formulae
%
% E = 1 - poisson ratio
% E = c * G * |b|^2,  - G - Schubmodul / Shear Modulus Energy per (unit length)^2

