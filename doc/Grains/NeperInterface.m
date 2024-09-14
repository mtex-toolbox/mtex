%% Neper
%
%% General
% Neper is an open source software package for polycrystal generation and
% meshing developed by Romain Quey. It can be obtained from
% https://neper.info, where also the documentation is located.
%
% This module provides an comfortable interface to Neper. It is used 
% to simulate microstructures with certain parameters and load them back
% into MTEX for analysis and further investigation with the various tools 
% provided by MTEX.
%
% In order to do this, a slicing of the 3-dimensional tessellation is 
% necessary after the simulation. The obtained 2-dimensional tessellation 
% is processed as an object from the class |grain2d|. 
%
%
%% Setting-up the Neper instance
% If you do not want to make any further adjustments to the default values,
% this step could be done very easily. In this case please skip to chapter
% "Simulating a microstructure with Neper"

job = neperInstance

%% 
% File options:
% By default your Neper will work under the temporary folder of your MATLAB
% (MATLAB command |tempdir|). If you want to do your tessellations elsewhere or
% your tessellations are already located under another path, you can change
% it:

% for example
% job.filePath = 'C:\Users\user\Documents\work\MtexWork\neper';
% or
 job.filePath = [mtexDataPath filesep 'Neper'];

%%
% By default the 3d tesselation data will be named "allgrains" with the
% endings .tess and .ori and the 2d slices will be named "2dslice" with the
% ending .tess and .ori . You can change the file names in variables
% |fileName3d| and |fileName2d|.

job.fileName3d = 'my100grains';
job.fileName2d = 'my100GrSlice';

%% Tessellation options
% The grains will be generated in cubic domain. By default the domain has
% the edge length 1 in each direction. To change the size of the domain,
% store a row vector with 3 entries (x,y,z) in the variable |cubeSize|.

job.cubeSize = [4 4 2];

%%
% Neper uses an id to identify the tessellation. This integer value "is
% used as seed of the random number generator to compute the (initial) 
% seed positions" (neper.info/doc/neper_t.html#cmdoption-id) By default the
% tessellation id is always |1|.

job.id = 529;

%%
% Neper allows to specify the morphological properties of the cells. See
% <https://neper.info/doc/neper_t.html#cmdoption-morpho> for more
% information. By default grain growth is used, that is an alias for:

job.morpho = 'diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03)';

%% Simulating a microstructure with Neper
%
% The tessellation is executed by the command |simulateGrains|. There are
% two option to call it.
%
% # by an <ODFTheory.html ODF> and the number of grains
% # by a list of orientations. In this case the length of the list
% determines the number of grains.
%

cs = crystalSymmetry('432');
ori = orientation.rand(cs);
odf = unimodalODF(ori);
numGrains = 1000;

grains = job.simulateGrains(odf,numGrains,'silent')

%% plot the grains

clf
plot(grains,grains.meanOrientation)

how2plot = plottingConvention;
how2plot.outOfScreen = vector3d(-10,-5,2);
how2plot.east = vector3d(1,-2,0);
setCamera(how2plot)



%% Slicing
% We may generate arbitrary slices of the three dimensional grains using
% the command <grain3d.slice.html |slice|>. It is called by giving the
% normal vector |[a,b,c]| of the plane and either a point that lies in the
% plane or the distance of the plane to the origin.

% the normals of the slices
N = [vector3d(0,0,1),vector3d(1,-1,0),vector3d(2,2,4)];

% make all slices passing through this point
A = vector3d(2,2,1);

grains001 = grains.slice(N(1),A);
grains1_10= grains.slice(N(2),A);
grains224 = grains.slice(N(3),A);

%%
% the resulting slices are grain maps which we can visualize in 3d

plot(grains001,grains001.meanOrientation);
hold on
plot(grains1_10,grains1_10.meanOrientation);
hold on
plot(grains224,grains224.meanOrientation);
hold off

% set camera
setCamera(how2plot)

%%
% plot all grains intersecting a plane

inPlane = grains.intersected(N(1),A);

plot(grains001,grains001.meanOrientation);
hold on
plot(grains(inPlane),grains(inPlane).meanOrientation)
hold off

% set camera
setCamera(how2plot)
