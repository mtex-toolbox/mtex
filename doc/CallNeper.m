%% Neper
%
%% General
% Neper is an open source software package for polycrystal generation and
% meshing developed by Romain Query. It can be obtained from
% https://neper.info, where also the documentation is located.
%
%% General workflow
% A general workflow using neper conatins usually three parts:
% * setting up the neper instance
% * tesselation
% * slicing
% 
%% Simulating a microstructure with Neeper

%% Setting-up the neper instance
% If you do not want to make any further adjustments to the default values,
% this step could be done very easily:

myneper = neperInstance

%% 
% File options:
% By default your neper will work under the temporary folder of your matlab
% (matlab command |tempdir|). If you want to do your tesselations elsewhere or
% your tesselations are already located under another path, you can change
% it:

% for example
% myneper.filePath = 'C:\Users\user\Documents\work\MtexWork\neper';
% or
%myneper.filePath = pwd;

%%
% By default a new folder, named neper will be created for the tesselation 
% data. If you do not want to create a new folder you can switch it of by 
% setting |newfolder| to |false|.

myneper.newfolder = false;

%%
% If |newfolder| is true (default) the slicing module also works in the
% subfolder neper, if it exists.
%
% By deafult the 3d tesselation data will be named "allgrains" with the
% endings .tess and .ori and the 2d slices will be named "2dslice" with the
% ending .tess and .ori . You can change the file names in variables
% |fileName3d| and |fileName2d|.

myneper.fileName3d = 'my100grains';
myneper.fileName2d = 'my100GrSlice';

%% Tesselation options
% The grains will be generated in cubic domain. By default the domain has
% the edge length 1 in each direction. To change the size of the domain,
% store a row vector with 3 entries (x,y,z) in the variable |cubeSize|.

myneper.cubeSize = [4 4 2];

%%
% Neper uses an id to identify the tesselation. This interger value "is
% used as seed of the random number generator to compute the (initial) 
% seed positions" (neper.info/doc/neper_t.html#cmdoption-id) By default the
% tesselation id is always |1|.

myneper.id = 529;

%%
% Neper allows to specify the morphological properties of the cells. See
% <https://neper.info/doc/neper_t.html#cmdoption-morpho> for more
% information. By default graingrowth is used, that is an alias for:

myneper.morpho = 'diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03)';

%% Simulating a microstructure with Neeper
%
% The tesselation is executed by the command |simulateGrains|. There are
% two option to call it.
% 1. by ODF and number of grains:

cs = crystalSymmetry('432');
ori = orientation.rand(cs);
odf = unimodalODF(ori);
numGrains=100;

myneper.simulateGrains(odf,numGrains)

%%
% 2. by list of orientations:
% In this case the length of the list determines the number of Grains.

oriList=odf.discreteSample(numGrains);

myneper.simulateGrains(oriList)

%% Slicing
% To get slices of your tesselation, that you can process with MTEX, the
% command |getSlice| is used, wich returns a set of grains (|grain2d|). 
% It is called by giving the normal vector [a,b,c] of the plane and either 
% a point that lies in the plane or the "d" of the plane equation.

N=vector3d(0,0,1);
d=1;
slice001 = myneper.getSlice(N,d);

N=vector3d(1,-1,0);
A=vector3d(2,2,1);
mySlice2=myneper.getSlice(N,A);

N=vector3d(2,2,4);
A=vector3d(2,2,1);
mySlice3=myneper.getSlice(N,A);

%%
plot(mySlice1,mySlice1.meanOrientation);
hold on
plot(mySlice2,mySlice2.meanOrientation);
hold on
plot(mySlice3,mySlice3.meanOrientation);

% set camera



