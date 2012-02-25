%% EBSD Color Coding
% Explains EBSD color coding.
%
%% Open in Editor
%
%% Contents
%
% Let us first import some EBSD data by a [[matlab:edit loadaachen.m, script file]]

mtexdata aachen

%% See also
% EBSD/plotspatial grain/plotGrains ebsdColorbar orientation2color

%% Colorcoding of orientations
%
% In order to visualize orientation maps as they are measured by EBSD one
% has to assign a color to each possible orientation. As an example one may
% think of representing an orientation by its Euler angles ph1, Phi, phi2
% and taking these as the RGB values of a color. Of course there are many
% other ways to do this. Before presenting all the possibilities MTEX
% offers to assign a color to each orientation let us shortly summmarize
% what properties we expect from such an assignment.
%
% # crystallographic equivalent orientations should have the same color
% # similar orientations should have similar colors
% # different orientations should have different colors
% # the whole colorspace should be used for full contrast
% # if the orientations are concentrated in a small region of the
% orientationspace, the colorspace should be exhaust be this region
% 
% It should be noted that it is impossible all points 1-4 by a single
% colorcoding. This is mainly due the fact that the orientation space is
% three dimensional and the colorspace is only two dimensional, i.e., there
% are to few colors to cover the whoole orientation space in a unambiguous
% way. Hence, some compromises has to be acceptet.
%
%
%% Assigning the Euler angles to the RGB values
% Using the Euler angles as the RGB values is probably the most simplest
% way of colorcoding. However, it introduces a lot of artefacts at those
% points where different Euler angles describe almost the same orientation.
% That is point 2 of our requirement list is not satisfied. The following
% plot shows how the colorcoding covers the whoole orientation space. The
% singularities of this representation are quit obvious.

EBSDColorbar(symmetry('-1'),'colorcoding','Bunge','sections',6,'phi1')


%% Colorcoding according to inverse pole figure 
%
% The standard way of plotting EBSD data spatial is based on an inverse
% polfigure, looking onto the specime we see crystal directions

plot(ebsd('Fe'))

%%


pos = {'position',[100 100 400 250]};
colorbar(pos{:})

%%
% *HKL*. 
% Another inverse Polefigure colorcoding

close all; plot(ebsd('Fe'),'colorcoding','hkl')

%%
%
colorbar(pos{:})

odf = calcODF(ebsd('Fe'),'silent');
figure, plotipdf(odf,xvector,'antipodal','silent',pos{:})

%%
% We can change the default view onto the specime (xvector) by setting the option *r*

close all, plot(ebsd('Fe'),'colorcoding','hkl','r',zvector)

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
% there are many other ways to  <orientation2color.html, colorize>
% orientations

figure
plot(ebsd,'colorcoding','bunge')
plot(ebsd,'colorcoding','bunge2')
plot(ebsd,'colorcoding','ihs')
plot(ebsd,'colorcoding','rodrigues')
plot(ebsd,'colorcoding','euler')
