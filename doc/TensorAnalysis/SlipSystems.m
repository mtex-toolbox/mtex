%% Slip Systems
% How to analyze slip transmission at grain boundaries
%
%%
%
%
%% Open in Editor
%
%% Contents
%

%% Burgers vector and normal directions
% 
% Consider hexagonal symmetry of alpha-Titanium

cs = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)')

%%
% Then basal slip is defined by the Burgers vector (or slip direction)

b = Miller(2,-1,-1,0,cs,'UVTW')

%%
% and the slip plane normal

n = Miller(0,1,-1,0,cs,'HKIL')

%%
% Accordingly we can define a slip system in MTEX by

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

%% Rotating slip systems






