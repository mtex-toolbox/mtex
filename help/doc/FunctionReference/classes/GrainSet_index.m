%% Grains (The Class @GrainSet)
% class representing *grains* of spatially indexed individual orientations
%
%% Class Description
% A grain based analysis starts with <GrainReconstruction.html constructing
% grains>. We define a grain  as a region, in which the misorientation of
% neighbored measurements is less than a given threshold.

mtexdata forsterite
grains = calcGrains(ebsd,'angle',12.5*degree)

%%
%

plot(grains)

%% 
% A *GrainSet* holds topological information about a spatially indexed
% individual orientations. These are: 
%
% * an adjacency matrix $A_D: D \times D$ storing which measurements $D_{1,...,n}$ are
% neighboured
% * an incidence matrix $I_{DG}: D \times G$ storing which measurement $D_{1,...n}$ is
% incident to a grain $G_j$
% * an adjacency matrix $A_G: G \times G$ storing which grains $G_{1,...,m}$ are
% neighboured
%
% furthermore, there are two incidence matrices
%
% * $I_{FD}^{ext}: F \times D$ marking which faces $F_{1,...,k}$ of a measurement $D_i$
% belongs to the grain boundary.
% * $I_{FD}^{sub}: F \times D$ marking which face $F_{1,...,k}$ of a measurement $D_i$
% belongs to the grain boundary inside of a grain, i.e. is a subboundary.
%
% With this five sparse matrices, almost every task in grain based analysis
% can be processed reasonably.
%
% For some _geometrical_ reasons, we distinguish between
% <Grain2d_index.html *Grain2d*> and <Grain3d_index.html *Grain3d*>.
%
% The figure below illustrates basic interactions between a *GrainSet*, its
% *EBSD* data and the purpose towards *Orientation Analysis*. Further details are
% explained under the topic <GrainAnalysis.html Grain Analysis>.
%
% <<grain.png>>
%


