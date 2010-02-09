%% Misorientation Analysis
%
%% Open in Editor
%
%% Abstract
% This Article gives you an overview over the functionality MTEX offers to
% analyze misorientation behavior of EBSD Data and Grains. Beside the
% influence of the choosen high-angle theshold (see [[influence_demo.html,demo]]) on Misorientation
% there are manifold ways to explain boundary and intergranular grain
% properties and its texture.
% One could explain misorientation as the orientation needed to rotate
% $g_i$ uppon $g_j$ modulo crystal symmetry, or the other way round
% depending on the point of view.
%
% $$ g_{mis}(g_i,g_j) = g_i *g_j^{-1} $$
%
%
%% Contents
%
%% Import of EBSD Data
%
% Let us first import some EBSD data.

CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% import ebsd data
ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],...
  'ignorePhase', 0, 'Bunge');

plotx2east

%% Detect Grains
% First of all we have to regionalize our investigation area

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree)


%% Misorientation to Mean
% Let us inspect the [[grain_misorientation.html, misorientation]] from
% the assigned mean orientation of each grain to its corresponding ebsd
% data

mis2m_ebsd = misorientation(grains,ebsd)

%%
% first look on the misorientation distribution

figure, hist(mis2m_ebsd)


%% Misorientation to Neighboured Grains
% Futhermore we can use the orientation of each grain to calculate the
% orientation needed to be its neighbour grain, since we have crystal
% symmetrie, respectively different phases, this is done only to neighbours
% of the same phase. However, thereinafter we'll have to weight each
% performed rotation as to its area

mis2n_ebsd = misorientation(grains,'weighted')

%%
% 

figure, hist(mis2n_ebsd)

%%
% Now let us plot those two kinds of misorientation together. As one can
% see, the frequency decrease in the near of the choosen threshold

hist([mis2n_ebsd,mis2m_ebsd])
legend('phase(1) to neighbour','phase(2) to neighbour','phase(1) to mean','phase(2) to mean')
line([12.5 12.5],[0 1],'color','k','linestyle','--')
text(13.5,0.9,'threshold','rotation',-90)

%% Intergranular Misorientation Analysis
% Both misorientations are returned as a new ebsd object holding the
% calculations. We can plot the misorientation to mean, 

figure, 
plotspatial(mis2m_ebsd,'r',sph2vec(30*degree,22.5*degree),'antipodal')
hold on, plot(grains)

%%
% many grains are plotted allmost white, some colored, let us quantize this
% more precisely, for this purpose let us estimate for each grain its
% misorientation density function (MDF)

k = kernel('de la Vallee Poussin','halfwidth',2*degree)

grains = calcODF(grains,mis2m_ebsd,'kernel',k,'property','ODF_mis2mean')

%%
% the calculated ODFs are stored in a property of grain as 'ODF_mis2mean',
% the previous coloring correspondes somehow or other to the overall
% misorientation to mean of a phase, so let it compare this more precisely

mis2m_odf_ph1 = calcODF(mis2m_ebsd(1),'kernel',k)
mis2m_odf_ph2 = calcODF(mis2m_ebsd(2),'kernel',k)

error = grainfun(@calcerror,grains,'ODF_mis2mean',mis2m_odf_ph1,mis2m_odf_ph2);

%%

figure, plot(grains,'property',error)

%%

figure, hist(error)

%%
% let us take a look on the polefigures of the MDFs to mean of grains which
% are relativly different

odfs = get(grains(error > 0.85),'ODF_mis2mean');

figure('position',[100 100 800 200])
superposed = [odfs{:}];
plotpdf(superposed,[Miller(1,0,0) Miller(1,1,0), Miller(1,1,1)]), colorbar


%% Boundary Misorientation Analysis
% as spoken to above we have calculated a new ebsd object holding the
% misorientation to neighbours, however not the direct neighbours of grain
% boundary neighbours are taken but mean orientations of grains. also for
% this we can estimate an misorientation density function

k = kernel('de la Vallee Poussin','halfwidth',10*degree);

mis2n_odf = calcODF(mis2n_ebsd(1),'kernel',k);

%%
% let us compare it visually to the overall grains ODF

odf = calcODF(link(grains,ebsd(1)),'kernel',k);

figure('position',[100 100 800 200])
plotpdf(mis2n_odf,[Miller(1,0,0) Miller(1,1,0), Miller(1,1,1)]), colorbar

figure('position',[100 100 800 200])
plotpdf(odf,[Miller(1,0,0) Miller(1,1,0), Miller(1,1,1)]), colorbar

%%

calcerror(mis2n_odf,odf)


%% 
close all
