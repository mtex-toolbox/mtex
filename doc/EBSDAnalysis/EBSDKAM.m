%% Kernel Average Misorientation (KAM)
%
%%
% The kernel average misorientation asks a local question: by how much does
% the orientation at a point differ from the orientations right next to it?
% Averaging that difference over the neighbours gives one angle per pixel,
% and a map of it shows where the lattice is bent - which is where
% dislocations are stored. Unlike the grain reference orientation deviation
% of <EBSDGROD.html Mis2Mean / GROD>, it never looks further than a few
% pixels, so it says nothing about how far the grain as a whole has turned.
%
% Three things decide what comes out: how many rings of neighbours are
% counted, whether neighbours across a grain boundary are counted, and
% whether a difference that is too large to be plausible is discarded. The
% closing section writes this down as a formula.
%
%% A deformed ferrite specimen

mtexdata ferrite

[grains,ebsd] = calcGrains(ebsd,'minPixel',8);
grains = smoothBoundary(grains,5);

plot(ebsd('indexed'),ebsd('indexed').orientations)
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% <EBSD.KAM.html |ebsd.KAM|> computes it. Like every angle in MTEX the
% result is in radians, so dividing by |degree| puts it on a readable
% scale.

kam = ebsd.KAM / degree;

plot(ebsd,kam,'micronbar','off')
setColorRange([0,15])
mtexColorMap LaboTeX
mtexColorbar
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% By default the nearest neighbours are used, no difference is discarded,
% and - because |calcGrains| set |ebsd.grainId| above - neighbours in
% another grain are ignored. What dominates the picture is therefore the
% network of red lines running through the grains: subgrain boundaries,
% where the lattice turns abruptly. The median of this map is 0.60° and its
% maximum 24.6°, so those lines are more than an order of magnitude above
% the background and leave no colour range for anything else.
%
%% Discarding the subgrain boundaries
%
% A threshold does exactly that: neighbours differing by more than
% $\delta$ are left out of the average, so a subgrain boundary contributes
% nothing.

plot(ebsd,ebsd.KAM('threshold',2.5*degree) ./ degree,'micronbar','off')
setColorRange([0,2])
mtexColorbar
mtexColorMap LaboTeX
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% The network has largely gone and the map now shows the gentle bending
% between the boundaries. It is also visibly speckled, and that is the
% catch: what remains is of the order of a few tenths of a degree, which is
% the size of the measurement error itself.
%
%% Two ways to deal with the noise
%
% The first is to average over more neighbours - here everything up to
% three rings away.

plot(ebsd,ebsd.KAM('threshold',2.5*degree,'order',3) ./ degree,'micronbar','off')
setColorRange([0,2])
mtexColorbar
mtexColorMap LaboTeX
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% Smoother, but the price is visible: a larger kernel measures the
% orientation change over a larger distance, so the median rises from 0.59°
% to 0.81° and fine dislocation structures are smeared out along with the
% noise.
%
% The second way keeps the kernel small and removes the noise from the
% orientations instead, before the KAM is computed at all - see
% <EBSDDenoising.html Denoising>.

% chose a denoising filter
F = halfQuadraticFilter;
F.alpha = 0.5;

% denoise the orientation map
ebsdS = smooth(ebsd,F,'fill',grains);

% plot the first order KAM
plot(ebsdS,ebsdS.KAM('threshold',2.5*degree) ./ degree,'micronbar','off')
setColorRange([0,2])
mtexColorbar
mtexColorMap LaboTeX
hold on
plot(grains.boundary,'lineWidth',1.5)
hold off

%%
% This is the map to use. The median falls to 0.27°, less than half of what
% the threshold alone left, so more than half of that was measurement
% error - and the structures that survive are continuous features running
% through the grains rather than isolated pixels. They are the local
% dislocation structures of the deformed material.
%
%% The definition
%
% Writing $o_{i,j}$ for the orientation at pixel $(i,j)$ and $N(i,j)$ for
% the set of neighbours counted there,
%
% $$\mathrm{KAM}_{i,j} = \frac{1}{|N(i,j)|}\sum_{(k,l) \in N(i,j)} \omega(o_{i,j}, o_{k,l}) $$
%
% where $\omega$ is the disorientation angle between two orientations and
% $\lvert N(i,j)\rvert$ the number of neighbours. Everything on this page
% is a choice of $N(i,j)$:
%
% * neighbours up to order $n$, that is $n$ rings of pixels
% * only neighbours in the same grain
% * only neighbours closer than a threshold angle $\delta$
%
% The rings are numbered like this, on a square and on a hexagonal grid.

plotSquareNeighbours; nextAxis(1,2); plotHexNeighbours

%% Some helper functions
%
% The two functions below only draw the neighbourhood pictures above.

function plotSquareNeighbours

N = [4 3 2 3 4;...
  3 2 1 2 3;...
  2 1 0 1 2;...
  3 2 1 2 3;...
  4 3 2 3 4];

colors = getMTEXpref('PhaseColorOrder');
for k = 1:5
  csList(k) = crystalSymmetry;
  csList(k).color = colors{k};
end
ebsd = EBSDsquare([],rotation.nan(5,5),N,0:4,csList,'dxy',[10 10]);
plot(ebsd,'EdgeColor','black','micronbar','off','figSize','small','unitCell')
legend off

text(ebsd,N)

end

function plotHexNeighbours

N = [3 2 2 2 3;...
  2 1 1 2 3;...
  2 1 0 1 2;...
  2 1 1 2 3;...
  3 2 2 2 3;...
  3 3 3 3 4];

colors = getMTEXpref('PhaseColorOrder');
for k = 1:5
  csList(k) = crystalSymmetry;
  csList(k).color = colors{k};
end
ebsd = EBSDhex([],rotation.nan(6,5),N,0:4,csList,10,1,1);
plot(ebsd,'edgecolor','k','micronbar','off','figSize','small','unitCell')
legend off
text(ebsd,N)
axis off

end
