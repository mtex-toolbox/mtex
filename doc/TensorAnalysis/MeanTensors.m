%% Average Material Tensors
% how to calculate average material tensors from ODF and EBSD data
%%
% MTEX offers several ways to compute average material tensors from ODFs or EBSD data.
%
%% Open in Editor
%
%% Contents
%
%%
% set up a nice colormap
setMTEXpref('defaultColorMap',blue2redColorMap);

%% Import EBSD Data
% We start by importing some EBSD data of Glaucophane and Epidote.

ebsd = loadEBSD([mtexDataPath '/EBSD/data.ctf'],...
  'convertEuler2SpatialReferenceFrame')

%%
% Let's visualize a subset of the data

plot(ebsd(inpolygon(ebsd,[2000 0 1400 375])))


%% Data Correction
% next, we correct the data by excluding orientations with large MAD value

% define maximum acceptable MAD value
MAD_MAXIMUM= 1.3;

% eliminate all meassurements with MAD larger than MAD_MAXIMUM
ebsd(ebsd.mad >MAD_MAXIMUM) = []

plot(ebsd(inpolygon(ebsd,[2000 0 1400 375])))

%% Define Elastic Stiffness Tensors for Glaucophane and Epidote
%
% Glaucophane elastic stiffness (Cij) Tensor in GPa
% Bezacier, L., Reynard, B., Bass, J.D., Wang, J., and Mainprice, D. (2010)
% Elasticity of glaucophane and seismic properties of high-pressure low-temperature
% oceanic rocks in subduction zones. Tectonophysics, 494, 201-210.

% define the tensor coefficients
MGlaucophane =....
  [[122.28   45.69   37.24   0.00   2.35   0.00];...
  [  45.69  231.50   74.91   0.00  -4.78   0.00];...
  [  37.24   74.91  254.57   0.00 -23.74   0.00];...
  [   0.00    0.00    0.00  79.67   0.00   8.89];...
  [   2.35   -4.78  -23.74   0.00  52.82   0.00];...
  [   0.00    0.00    0.00   8.89   0.00  51.24]];

% define the reference frame
csGlaucophane = crystalSymmetry('2/m',[9.5334,17.7347,5.3008],...
  [90.00,103.597,90.00]*degree,'X||a*','Z||c','mineral','Glaucophane');

% define the tensor
CGlaucophane = stiffnessTensor(MGlaucophane,csGlaucophane)

%%
% Epidote elastic stiffness (Cij) Tensor in GPa
% Aleksandrov, K.S., Alchikov, U.V., Belikov, B.P., Zaslavskii, B.I. and Krupnyi, A.I.: 1974
% 'Velocities of elastic waves in minerals at atmospheric pressure and
% increasing the precision of elastic constants by means of EVM (in Russian)',
% Izv. Acad. Sci. USSR, Geol. Ser.10, 15-24.

% define the tensor coefficients
MEpidote =....
  [[211.50    65.60    43.20     0.00     -6.50     0.00];...
  [  65.60   239.00    43.60     0.00    -10.40     0.00];...
  [  43.20    43.60   202.10     0.00    -20.00     0.00];...
  [   0.00     0.00     0.00    39.10      0.00    -2.30];...
  [  -6.50   -10.40   -20.00     0.00     43.40     0.00];...
  [   0.00     0.00     0.00    -2.30      0.00    79.50]];

% define the reference frame
csEpidote= crystalSymmetry('2/m',[8.8877,5.6275,10.1517],...
  [90.00,115.383,90.00]*degree,'X||a*','Z||c','mineral','Epidote');

% define the tensor
CEpidote = stiffnessTensor(MEpidote,csEpidote)

%% The Average Tensor from EBSD Data
% The Voigt, Reuss, and Hill averages for all phases are computed by

[CVoigt,CReuss,CHill] =  calcTensor(ebsd({'Epidote','Glaucophane'}),CGlaucophane,CEpidote)

%%
% for a single phase the syntax is

[CVoigtEpidote,CReussEpidote,CHillEpidote] =  calcTensor(ebsd('Epidote'),CEpidote)


%% ODF Estimation
% Next, we estimate an ODF for the Epidote phase

odfEpidote = calcODF(ebsd('Epidote').orientations,'halfwidth',10*degree)


%% The Average Tensor from an ODF
% The Voigt, Reuss, and Hill averages for the above ODF are computed by

[CVoigtEpidote, CReussEpidote, CHillEpidote] =  ...
  calcTensor(odfEpidote,CEpidote)

% set back the colormap
setMTEXpref('defaultColorMap',WhiteJetColorMap);
