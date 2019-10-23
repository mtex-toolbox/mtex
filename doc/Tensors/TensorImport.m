%% Importing Tensor Data
%
%%
% Single crystal tensor are imported using the command <tensor.load.html
% tensor.load>. This function automatically detect the file format and
% imports the data. In dependency of the specific format it might be
% necessary to specify the crystal symmetry seperately

% define crystal symmetry
CS = crystalSymmetry('32', [4.916 4.916 5.4054],...
  'X||a*', 'Z||c', 'mineral', 'Quartz');

% define the file name
fname = fullfile(mtexDataPath,'tensor', 'Single_RH_quartz_poly.P');

% import the single crystal tensor
P = tensor.load(fname,CS,'propertyname','piecoelectricity','unit','C/N','DoubleConvention')

%%
% For specific types of tensors, e.g. stiffness tensors there exist
% dedicated import functions that have the form *tensorName.load*

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

C = stiffnessTensor.load(fname,cs)
