%% Grain Neighbors
%
% TODO: This page needs to be improved
%%%
%
% In this section we discuss .... We
% start our discussion by reconstructing the grain structure from a sample
% EBSD data set.

% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed')

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree)

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off


%%

% The function neighbors for grains returns the (i) the number of neighbors
% of the grains in the EBSD map and (ii) the possible pairs of grains with
% this map. This is defined in MTEX as

[g_NN, g_PAIRS] = grains.neighbors; % grain pairs are given by grain.Id

% A simple histogram showing the distribution of number of neighbors in the
% map can be plotted as

figure(1)
histogram(g_NN,0:1:20)
xlabel('Number of neighbors')
ylabel('Number of counts')

% whereas pairs generates a list of grain pairs of size size N x 2, where 
% $$N = 2 \sum n_i $$ is the total number of neighborhood relations 
% (without self-reference). In this case, pairs(i,:) gives the indexes of
% two neighboring grains

%%

% take a specific grain
id = 94;
plot(grains(id),'micronbar','off','FaceColor','Chocolate','displayName','id=94')

% extract neighbors of this grain
[~,neighbors] = grains(id).neighbors;
neighbors(neighbors == id) = [];

% plot the neighbors
hold on
plot(grains(neighbors));
hold off
