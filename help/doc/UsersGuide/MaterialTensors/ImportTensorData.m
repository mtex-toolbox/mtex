%% Importing Tensor Data
% How to import Tensor Data
%

%% Contents
%
%% Importing Tensor data using the import wizard
%
% The most simplest way to load Tensor data is to use the 
% <matlab:import_wizard('tensor') import wizard>, which 
% can be started either by typing into the command line 

import_wizard('tensor'); 

%% The generic interface


fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

C = loadTensor(fname,cs,'name','ellastic stiffness','unit','Pa','interface','generic')
