%% Dislocation Systems (The Class @dislocationSystem)
% This section describes the class *dislocationSystem*.
%
%% Open in Editor
%
%% Contents
%
%% Class Description 
% Dislocation are microscopic displacements within the regular atom
% lattice of a crystaline material ussualy as a result of plastic
% deformation. Dislocations are described by a Burgers vector describing
% the direction of the atomic shift and a line vector describing the
% direction of the displacements within the material. One distinguishes two
% cases:


%% SUB: Edge Dislocations
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


%% SUB: Screw Dislocations
% Screw dislocations are characterized by the fact that Burgers vector and
% line vector are perpendicular to each other.

% define a burgers vector in crystal coordinates
b = Miller(1,1,0,cs,'uvw')

% define a line vector in crystal coordinates
l = Miller(1,1,0,cs,'uvw')

% setup the dislocation system
dS = dislocationSystem(b,l)


%% SUB: Slip Systems
% Dislocation systems are tightly related to <slipSystem_index.html slip
% systems>. Given a set of slip systems the corresponding dislocation
% systems can be computed by

% dominant slip systems in cubic fcc material
sS = symmetrise(slipSystem.fcc(cs))

% the corresponding dislocation systems
dS = dislocationSystem(sS)

%% SUB: Dominant Dislocation Systems
%

dS = dislocationSystem.bcc(cs)


%% The Dislocation Tensor
% As each dislocation corresponds to an deformation of the atom lattice a
% dislocation can also be described by a deformation matrix. This matrix is
% the dyadic product between the Burgers vector and the line vector and can
% be computed by

dS.tensor

%%
% The unit of the deformation tensor is the unit of the burgers vector
% which is assumet to be au in MTEX.

