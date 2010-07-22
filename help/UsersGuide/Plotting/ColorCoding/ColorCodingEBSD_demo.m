%% EBSD Color Coding
% Explains how to control EBSD color coding.
%
%% Open in Editor
%
%% Contents
%
% Let us first import some EBSD data by a [[matlab:edit loadaachen.m, script file]]

loadaachen

%% See also
% EBSD/plotspatial grain/plotgrains ebsdColorbar orientation2color

%% IPDF Colorcoding
% *IPDF*. 
% the standard way of plotting EBSD data spatial is based on an inverse
% polfigure, looking onto the specime we see crystal directions

plotspatial(ebsd,'phase',1)

%%


pos = {'position',[100 100 400 250]};
colorbar(pos{:})

%%
% *HKL*. 
% Another inverse Polefigure colorcoding

close all; plotspatial(ebsd,'phase',1,'colorcoding','hkl')

%%
%
colorbar(pos{:})

odf = calcODF(ebsd,'phase',1,'silent');
figure, plotipdf(odf,xvector,'antipodal','silent',pos{:})

%%
% We can change the default view onto the specime (xvector) by setting the option *r*

close all, plotspatial(ebsd,'phase',1,'colorcoding','hkl','r',zvector)

%%
%
colorbar(pos{:})
figure, plotipdf(odf,zvector,'antipodal','silent',pos{:})

%%
close all

%% IPDF Overview
% standard colorcoding and the so called (antipodal) oxford colorcoding

%% 
% *triclinic symmetry*
ebsdColorbar(symmetry('-1'),pos{:})
ebsdColorbar(symmetry('-1'),'colorcoding','hkl','position',[100 100 400 210])

%%
% *monoclinic symmetry*
ebsdColorbar(symmetry('2/m'),pos{:})
ebsdColorbar(symmetry('2/m'),'colorcoding','hkl','position',[100 100 250 250])

%%
% *orthorhombic symmetry*
ebsdColorbar(symmetry('mmm'),pos{:})
ebsdColorbar(symmetry('mmm'),'colorcoding','hkl','position',[100 100 211 211])

%%
% *tetragonal symmetry*
ebsdColorbar(symmetry('4/m'),pos{:})
ebsdColorbar(symmetry('4/m'),'colorcoding','hkl','position',[100 100 211 211])

%% 
% *trigonal symmetry*
ebsdColorbar(symmetry('-3'),pos{:})
ebsdColorbar(symmetry('-3'),'colorcoding','hkl','position',[100 100 300 148])

%%
%
ebsdColorbar(symmetry('-3m'),pos{:})
ebsdColorbar(symmetry('-3m'),'colorcoding','hkl','position',[100 100 250 250])

%%
%
ebsdColorbar(symmetry('4/mmm'),pos{:})
ebsdColorbar(symmetry('4/mmm'),'colorcoding','hkl','position',[100 100 250 250])

%% 
% *hexagonal symmetry*
ebsdColorbar(symmetry('6/m'),pos{:})
ebsdColorbar(symmetry('6/m'),'colorcoding','hkl','position',[100 100 211 211])

%%
%
ebsdColorbar(symmetry('6/mmm'),pos{:})
ebsdColorbar(symmetry('6/mmm'),'colorcoding','hkl','position',[100 100 285 250])

%% 
% *cubic symmetry*
ebsdColorbar(symmetry('m-3m'),pos{:})
ebsdColorbar(symmetry('m-3m'),'colorcoding','hkl','position',[100 100 285 197])


%% Other Colorcodes
% there are many other ways to  [[orientation2color.html, colorize]]
% orientations

figure
plotspatial(ebsd,'colorcoding','bunge')
plotspatial(ebsd,'colorcoding','bunge2')
plotspatial(ebsd,'colorcoding','ihs')
plotspatial(ebsd,'colorcoding','rodrigues')
plotspatial(ebsd,'colorcoding','euler')
