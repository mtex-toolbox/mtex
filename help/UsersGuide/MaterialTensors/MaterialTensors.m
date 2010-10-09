%% Material Tensors
%
%
%% Working with tensors


CS = symmetry('orthorhombic',[4.7601 10.2012  5.9850],[90,90,90]*degree,'Fosterite');
SS = symmetry('-1')


%% Import some individual orientations

fname = fullfile(mtexDataPath,'tensor','129a_ABC_ol_EULER');

ebsd = loadEBSD(fname,CS,SS,'interface','generic' ...
  , 'ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3'}, 'Columns', [2 3 4], 'Bunge', 'passive rotation', 'ignorePhase', 0);


%% Import some Tensor Data

% path to files
fname = fullfile(mtexDataPath,'tensor','Fosterite_PC_model.TEXP');

T = loadTensor(fname,CS,'interface','generic');


%% Calculate an mean tensor for the material

Tv = calcTensor(ebsd,T,'voigt');

[min(Tv) max(Tv)]

plot(Tv,'contourf','complete')




