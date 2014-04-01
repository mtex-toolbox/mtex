%% EBSD Color Coding
% Explains EBSD color coding.
%
%% Open in Editor
%
%% Contents
%
% Let us first import some EBSD data

mtexdata forsterite

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

ebsdColorbar(symmetry('-1'),'colorcoding','BungeRGB','sections',6,'phi1')


%% Colorcoding according to inverse pole figure 
%
% The standard way of plotting EBSD data in orientation maps is based on an inverse
% pole figure color coding. Through these color code, one can make a direct relationship
% between diffent grains and their respective crystal directions in relation to one of the axis
% of the sample reference frame (xvector, yvector or zvector).

close all
plot(ebsd('Fo'))

%%

colorbar

%%
% *HKL*. 
% Another inverse Pole figure color code

% TODO
%close all; plot(ebsd('Fo'),'colorcoding','ipdfHKL')

%%
%
colorbar

odf = calcODF(ebsd('Fo'),'silent');
figure, plotIPDF(odf,xvector,'antipodal','silent')

%%
% We can change the default view onto the specimen (xvector) by setting the option *r*

close all, plot(ebsd('Fo'),'r',zvector)

%%
%
colorbar
figure, plotIPDF(odf,zvector,'antipodal','silent')

%%
close all

%% IPDF Overview
% standard colorcoding with and without antipodal symmetry

%% 
% *triclinic symmetry*
ebsdColorbar(symmetry('1'))
ebsdColorbar(symmetry('-1'),'antipodal')

%%
% *monoclinic symmetry*
ebsdColorbar(symmetry('2/m'))
ebsdColorbar(symmetry('2/m'),'antipodal')

%%
% *orthorhombic symmetry*
ebsdColorbar(symmetry('mmm'))
ebsdColorbar(symmetry('mmm'),'antipodal')

%%
% *tetragonal symmetry*
ebsdColorbar(symmetry('4/m'))
ebsdColorbar(symmetry('4/m'),'antipodal')

%% 
% *trigonal symmetry*
ebsdColorbar(symmetry('-3'))
ebsdColorbar(symmetry('-3'),'antipodal')

%%
%
ebsdColorbar(symmetry('-3m'))
ebsdColorbar(symmetry('-3m'),'antipodal')

%%
%
ebsdColorbar(symmetry('4/mmm'))
ebsdColorbar(symmetry('4/mmm'),'antipodal')

%% 
% *hexagonal symmetry*
ebsdColorbar(symmetry('6/m'))
ebsdColorbar(symmetry('6/m'),'antipodal')

%%
%
ebsdColorbar(symmetry('6/mmm'))
ebsdColorbar(symmetry('6/mmm'),'antipodal')

%% 
% *cubic symmetry*
ebsdColorbar(symmetry('m-3'))
ebsdColorbar(symmetry('m-3'),'antipodal')

%% 
% 
ebsdColorbar(symmetry('m-3m'))
ebsdColorbar(symmetry('m-3m'),'antipodal')

