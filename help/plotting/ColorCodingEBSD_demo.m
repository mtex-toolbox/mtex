%% Color Coding
%
%% Open in Editor
%
%% Abstract
% When plotting [[EBSD_index.html, EBSD]] or [[grain_index.html, grains]]
% spatially one might colorize orientations for interpretation purposes.
%
%% Contents
%
%% Prelimery  
% Let us first import some EBSD data:


cs = { symmetry('cubic') };
ss = symmetry('triclinic');
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,... 
                'interface','generic','Bunge',...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'},...
                 'ignorePhase',[0 2],...
                 'Columns', [2 3 4 5 6 7]);

%% IPDF Colorcoding
% the standard way of plotting EBSD data spatial is based on an inverse polfigure

plotspatial(ebsd)

%%
% 
colorbar

%%
%

plotspatial(ebsd,'colorcoding','hkl')

%%
%
colorbar

%% IPDF Overview
% standard colorcoding and the so called (antipodal) oxford colorcoding

p = get(0,'DefaultFigurePosition');
set(0,'DefaultFigurePosition',[100 100 400 250]);

%% 
% *triclinic symmetry*
ebsdColorbar(symmetry('-1'))
ebsdColorbar(symmetry('-1'),'colorcoding','hkl')

%%
% *monoclinic symmetry*
ebsdColorbar(symmetry('2/m'))
ebsdColorbar(symmetry('2/m'),'colorcoding','hkl')

%%
% *orthorhombic symmetry*
ebsdColorbar(symmetry('mmm'))
ebsdColorbar(symmetry('mmm'),'colorcoding','hkl')

%%
% *tetragonal symmetry*
ebsdColorbar(symmetry('4/m'))
ebsdColorbar(symmetry('4/m'),'colorcoding','hkl')

%% 
% *trigonal symmetry*
ebsdColorbar(symmetry('-3'))
ebsdColorbar(symmetry('-3'),'colorcoding','hkl')

%%
%
ebsdColorbar(symmetry('-3m'))
ebsdColorbar(symmetry('-3m'),'colorcoding','hkl')

%%
%
ebsdColorbar(symmetry('4/mmm'))
ebsdColorbar(symmetry('4/mmm'),'colorcoding','hkl')

%% 
% *hexagonal symmetry*
ebsdColorbar(symmetry('6/m'))
ebsdColorbar(symmetry('6/m'),'colorcoding','hkl')

%%
%
ebsdColorbar(symmetry('6/mmm'))
ebsdColorbar(symmetry('6/mmm'),'colorcoding','hkl')

%% 
% *cubic symmetry*
ebsdColorbar(symmetry('m-3m'))
ebsdColorbar(symmetry('m-3m'),'colorcoding','hkl')

%%
%
set(0,'DefaultFigurePosition',p);

%% Other Colorcodes
% there are many other ways to  [[orientation2color.html, colorize]]
% orientations

figure
plotspatial(ebsd,'colorcoding','bunge')
plotspatial(ebsd,'colorcoding','bunge2')
plotspatial(ebsd,'colorcoding','ihs')
plotspatial(ebsd,'colorcoding','rodrigues')
plotspatial(ebsd,'colorcoding','euler')
