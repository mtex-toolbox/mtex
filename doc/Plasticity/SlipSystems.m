%% Slip Systems
%
%%
% Plastic deformation in crystalline materials almost exclusively appears
% as dislocation along lattice planes. Such deformations are described by
% the normal vector *n* of the lattice plane and direction *b* of the slip.
% In the case of hexagonal alpha-Titanium with

cs = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)')

%%
% basal slip is defined by the Burgers vector (or slip direction)

b = Miller(2,-1,-1,0,cs,'UVTW')

%%
% and the slip plane normal

n = Miller(0,1,-1,0,cs,'HKIL')

%%
% Putting both ingredients together we can define a slip system in MTEX by

sSBasal = slipSystem(b,n)

%%
% The most important slip systems for cubic, hexagonal and trigonal crystal
% lattices are already implemented into MTEX. Those can be accessed by

sSBasal = slipSystem.basal(cs)

%%
% Drawn inside the crystal, a slip system is a plane and an arrow in it. The
% plane is where the lattice shears and the arrow is the direction it shears
% along, so both are needed - the same plane with a different direction in it
% is a different slip system.

cS = crystalShape.hex(cs);

plot(cS,'faceAlpha',0.4,'faceColor',[0.7 0.8 0.9])
hold on
plot(cS,sSBasal,'faceColor','red')
hold off

%%
% Obviously, this is not the only basal slip system in hexagonal lattices.
% There are also symmetrically equivalent ones, which can be computed by

sSBasalSym = sSBasal.symmetrise('antipodal')

%%
% The length of the burgers vector, i.e., the amount of displacement is

sSBasalSym.b.norm

%% Predefined slip systems
% For cubic lattices the whole set of slip systems comes as one command,
% |slipSystem.fcc(cs)| and |slipSystem.bcc(cs)|. For hexagonal lattices
% there is deliberately no |slipSystem.hcp|: which families carry the
% deformation, and at which critical resolved shear stress (CRSS), is a
% property of the material and of the experiment rather than of the
% lattice. The families are predefined individually and are meant to be
% combined as the material at hand asks for
%
%   slipSystem.basal(cs)          <11-20>{0001}
%   slipSystem.prismaticA(cs)     <2-1-10>{01-10}
%   slipSystem.prismatic2A(cs)    <01-10>{2-1-10}     2nd order prismatic
%   slipSystem.pyramidalA(cs)     <2-1-10>{01-11}     1st order pyramidal <a>
%   slipSystem.pyramidalCA(cs)    <2-1-13>{-1101}     1st order pyramidal <c+a>
%   slipSystem.pyramidal2CA(cs)   <2-1-13>{-2112}     2nd order pyramidal <c+a>
%   slipSystem.twinT1(cs)         <1-101>{-1102}      tensile twinning
%   slipSystem.twinT2(cs)         <2-1-16>{-2111}     tensile twinning
%   slipSystem.twinC1(cs)         <-110-2>{-1101}     compressive twinning
%   slipSystem.twinC2(cs)         <2-1-1-3>{2-1-12}   compressive twinning
%
% The second argument of each is the CRSS of that family, which is what
% makes the families comparable to each other

sS = [slipSystem.basal(cs,1), slipSystem.prismatic2A(cs,66), ...
  slipSystem.pyramidalCA(cs,80), slipSystem.twinC1(cs,100)]

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

%#ok<*NASGU>

