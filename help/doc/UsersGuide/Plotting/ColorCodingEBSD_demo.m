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
% orientation space, the colorspace should be exhaust by this region
% 
% It should be noted that it is impossible to have all the 4 points mentioned above
% represented by a single colorcoding. This is mainly due the fact that 
% the orientation space is three dimensional and the colorspace is only two dimensional, 
% i.e., there are to few colors to cover the whole orientation space in a unambiguous
% way. Hence, some compromises has to be accepted and some assumptions have to be made.
%
%
%% Assigning the Euler angles to the RGB values
% Using the Euler angles as the RGB values is probably the most simplest
% way of colorcoding. However, it introduces a lot of artefacts at those
% points where different Euler angles describe almost the same orientation.
% In this case, the point 2 of our requirement list is not satisfied. The following
% plot shows how the colorcoding covers the whole orientation space. The
% singularities of this representation are quite obvious.

ebsdColorbar(symmetry('-1'),'colorcoding','Bunge','sections',6,'phi1')


%% Colorcoding according to inverse pole figure 
%
% The standard way of plotting EBSD data in orientation maps is based on an inverse
% pole figure color coding. Through these color code, one can make a direct relationship
% between diffent grains and their respective crystal directions in relation to one of the axis
% of the sample reference frame (xvector, yvector or zvector).

plot(ebsd('Fe'))

%%


pos = {'position',[100 100 400 250]};
colorbar(pos{:})

%%
% *HKL*. 
% Another inverse Pole figure color code

close all; plot(ebsd('Fe'),'colorcoding','hkl')

%%
%
colorbar(pos{:})

odf = calcODF(ebsd('Fe'),'silent');
figure, plotipdf(odf,xvector,'antipodal','silent',pos{:})

%%
% We can change the default view onto the specimen (xvector) by setting the option *r*

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

close all, plot(ebsd,'colorcoding','bunge')
close, plot(ebsd,'colorcoding','bunge2')
close, plot(ebsd,'colorcoding','ihs')
close, plot(ebsd,'colorcoding','euler')
