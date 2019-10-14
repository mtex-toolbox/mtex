%% Dislocations
%
%%
% TODO
%%
% Dislocation 



cs = crystalSymmetry('432');

sS = slipSystem.bcc(cs)

%%

dS = dislocationSystem(sS)

%%


dS = dislocationSystem.bcc(cs)

%%
% Here the norm of the Burgers vectors is important

% size of the unit cell
a = norm(ebsd.CS.aAxis);

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
%R = 
%r_0 = 
%U = norm(dS.b).^2

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

%%
% A single dislocation causes a deformation that can be represented by
% the rank one tensor

dS(1).tensor

%%
% Note that the unit of this tensors is the same as the unit used for
% describing the length of the unit cell, which is in most cases Angstrom
% (au). Furthremore, we observe that the tensor is given with respect to
% the crystal reference frame while the dislocation densitiy tensors are
% given with respect to the specimen reference frame. Hence, to make them
% compatible we have to rotate the dislocation tensors into the specimen
% reference frame as well. This is done by

dSRot = ebsd.orientations * dS


