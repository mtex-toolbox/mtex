%% Slip Systems
%
% Plastic deformation in crystaline materials almost exclusively appears as
% dislocation along lattice planes. Such deformations are described by the
% normal vector *n* of the lattice plane and direction *b* of the slip. In
% the case of hexagonal alpha-Titanium with 

cs = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)')

%%
% basal slip is defined by the Burgers vector (or slip direction)

b = Miller(2,-1,-1,0,cs,'UVTW')

%%
% and the slip plane normal

n = Miller(0,1,-1,0,cs,'HKIL')

%%
% Putting both incredience together we can define a slip system in MTEX by

sSBasal = slipSystem(b,n)

%%
% The most important slip systems for cubic, hexagonal and trigonal crystal
% lattices are already implemented into MTEX. Those can be accessed by

sSBasal = slipSystem.basal(cs)

%%
% Obviously, this is not the only basal slip system in hexagonal lattices.
% There are also symmetrically equivalent ones, which can be computed by

sSBasalSym = sSBasal.symmetrise('antipodal')

%%
% The length of the burgers vector, i.e., the amount of displacment is

sSBasalSym.b.norm

%% Displacement
% In linear theory the displacement of a slip system is described by the
% strain tensor 

sSBasal.deformationTensor

%%
% This displacement tensor is exactly the same as the so called Schmid
% tensor

sSBasal.SchmidTensor


%% Rotating slip systems
% By definition the slip system and accordingly the deformation tensor are
% with the respect to the crystal coordinate system. In order to transform
% the quantities into specimen coordinates we have to multiply with some
% grain orientation

% some random grain orientation
ori = orientation.rand(cs)

% transfer slip system into specimen coordinates
ori * sSBasal




