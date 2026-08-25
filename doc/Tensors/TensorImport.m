%% Importing Tensor Data
%
%%
% A tensor file holds numbers and nothing else. What it does not hold is the
% crystal symmetry and the frame the numbers refer to, and neither can be
% guessed - a stiffness tensor written in a frame with |X||a| and one written
% with |X||a*| look identical on disk and describe different materials. Both
% are therefore given at import.

% define crystal symmetry
CS = crystalSymmetry('32', [4.916 4.916 5.4054],...
  'X||a*', 'Z||c', 'mineral', 'Quartz');

% define the file name
fname = fullfile(mtexDataPath,'tensor', 'Single_RH_quartz_poly.P');

% import the single crystal tensor
P = tensor.load(fname,CS,'propertyname','piezoelectricity','unit','C/N','DoubleConvention')

%%
% <tensor.load.html |tensor.load|> recognises the file format on its own.
% What it cannot recognise is the convention the coefficients were written
% in: |'DoubleConvention'| above says that the off diagonal entries of the
% Voigt matrix carry a factor of two, as several sources write them and
% others do not. Getting it wrong scales part of the tensor silently.
%
% |'propertyname'| and |'unit'| are labels. They are carried along and
% printed, and they are the only record of what the numbers mean.

%%
% For the common tensor types there is a dedicated loader, which knows the
% conventions of that kind of file:

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

C = stiffnessTensor.load(fname,cs)

%%
% The result is a |@stiffnessTensor| rather than a plain |@tensor|, so the
% commands that only make sense for elasticity - the moduli, the wave
% velocities, <TensorAverage.html the polycrystal averages> - are available
% on it.
