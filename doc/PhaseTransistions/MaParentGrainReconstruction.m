%% Martensite Parent Grain Reconstruction
%
%% 
% This script demonstrates the tools MTEX offers to reconstruct a parent
% martensite phase from a measured austenite phase. Most of the ideas are
% from
% <https://www.researchgate.net/deref/http%3A%2F%2Fdx.doi.org%2F10.1007%2Fs11661-018-4904-9?_sg%5B0%5D=gRJGzFvY4PyFk-FFoOIj2jDqqumCsy3e8TU6qDnJoVtZaeUoXjzpsGmpe3TDKsNukQYQX9AtKGniFzbdpymYvzYwhg.5jfOl5Ohgg7pW_6yACRXN3QiR-oTn8UsxZjTbJoS_XqwSaaB7r8NgifJyjSES2iXP6iOVx57sy8HC4q2XyZZaA
% Crystallography, Morphology, and Martensite Transformation of Prior
% Austenite in Intercritically Annealed High-Aluminum Steel> by Tuomo
% Nyyssönen. We shall use the following sample data set.

% load the data
mtexdata martensite 

% extract fcc and bcc symmetries
csBCC = ebsd.CSList{2}; % austenite bcc:
csFCC = ebsd.CSList{3}; % martensite fcc:

% grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);

% remove small grains
ebsd(grains(grains.grainSize < 4)) = [];

% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);

% plot the data and the grain boundaries
plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% Determine the parent child orientation relationship
% It is well known that the phase transformation from martensite to
% austenite is not described by a fixed orientation relationship. In fact,
% the actual orientation relationship needs to be determined for each
% sample individualy. Here, we used the iterative methos proposed by Tuomo
% Nyyssönen and implemented in the function <calcParent2Child.html
% |calcParent2Child|> that starts at an initial guess of the orientation
% relation ship and iterates towards the true orientation relationship.
%
% Here we use as the initial guess the Kurdjumov Sachs orientation
% relationship

% initial gues is Kurdjumov Sachs
KS = orientation.KurdjumovSachs(csFCC,csBCC);

%%
% The function <calcParent2Child.html |calcParent2Child|> requires as input
% a list of child to child misorientations or, equivalently, a two column
% matrix of child orientations. Here we go with the second option and setup
% this two column orientation matrix from the mean orientations of
% neighbouring grains which can be found using the command
% <grain2d.neighbours.html |neighbours|>

% get neighbouring grain pairs
grainPairs = grains.neighbors;

% compute an optimal parent to child orientation relationship
[fcc2bcc, fit] = calcParent2Child(grains(grainPairs).meanOrientation,KS);

% display the distribution of disorientations with respect to this
% orientation relationship
close all
histogram(fit./degree)
xlabel('disorientation angle')

%% Create a similarity matrix
%
% Next we set up a adjecency matrix |A| that describes the probability that
% two neighbouring grains belong to the same parent grains. This
% probability is is computed from the misfit of misorientation between to
% child grains to the theoretical child to child misorientation. Here we
% use the cumulativ density function of the Burr distribution to map the
% misfit in degree into the interval [0,1]. The matrix |A| is than split
% into clusters using the command <calcCluster.html |calcCluster|> which
% implements the Marlovian clustering algorithm.

% the probability that two child grains belong to the same parent grain
sim = 1-cdf('Burr',fit./degree,2,5,1);

% the corresponding similarity matrix
A = sparse(grainPairs(:,1),grainPairs(:,2),sim,length(grains),length(grains));

% apply the Markovian clustering algorithm
p = 1.6; % inflation power:
A = mclComponents(A,p);

%%
% Each connected component of the resulting adjecency matrix describes one
% parent grain. Hence, we can use this adjecency matrix to merge child
% grains into parent grains by the command <graind2d.merge.html |merge|>.

% merge grains according to the adjecency matrix A
[parentGrains, parentId] = merge(grains,A);

% ensure grainId in parentEBSD is set up correctly with parentGrains
parentEBSD = ebsd;
parentEBSD('indexed').grainId = parentId(ebsd('indexed').grainId);

%%
% Lets visualize the first result. Note, that at this stage it is not
% important to have the parent grain already at their optimal size.
% Similarly orientated grains can be merged later on.

plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')
hold on;
plot(parentGrains.boundary,'linewidth',5)
hold off

%% Compute parent grain orientations
% In the next step we compute for each parent grain its parent martensite
% orientation. This can be done usig the command <calcParent.html
% |calcParent|>. Note, that we ensure that et least two child grains have
% been merged and that the misfit is smaller the 5 degree.

% the measured child orientations
childOri = grains('Iron bcc').meanOrientation;

% the parent orientation we are going to compute
parentOri = orientation.nan(max(parentId),1,fcc2bcc.CS);
fit = inf(size(parentOri));
weights = grains('Iron bcc').grainSize;

% loop through all parent grains
for k = 1:max(parentId)
  if nnz(parentId==k) > 1
    % compute the parent orientation from the child orientations
    [parentOri(k),fit(k)] = calcParent(childOri(parentId==k), fcc2bcc,'weights',weights((parentId==k)));
  end
  progress(k,max(parentId));
end

% update mean orientation of the parent grains
parentGrains(fit<5*degree).meanOrientation = parentOri(fit<5*degree);
parentGrains = parentGrains.update;

% merge grains with similar orientation
%[parentGrains, parentId] = merge(parentGrains,'threshold',3*degree);
%parentEBSD('indexed').grainId = parentId(parentEBSD('indexed').grainId);

%%
% Lets plot the resulting parent orientations

plot(parentGrains('Iron fcc'),parentGrains('Iron fcc').meanOrientation)

%%
% Once parent grain orientations have been computed we may use them to
% compute parent orientations of each pixel in our original EBSD map. To
% this end we first find a pixels that now belong to a martensite grain.

% consider only austenite pixels that now belong to martensite grains
isNowFCC = parentGrains.phaseId(max(1,parentEBSD.grainId)) == 3 & parentEBSD.phaseId == 2;

% compute parent orientation
[parentEBSD(isNowFCC).orientations, fit] = calcParent(ebsd(isNowFCC).orientations,...
  parentGrains(parentEBSD(isNowFCC).grainId).meanOrientation,fcc2bcc);

% plot the result
plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,'figSize','large')

%%
% As a second output argument we obtain the |misfit| between the parent
% orientation computed for the pixel and the meanorientation of the
% corresponding parent grain. Lets plot this misfit as a map.

plot(parentEBSD(isNowFCC),fit ./ degree,'figSize','large')
mtexColorMap LaboTeX
mtexColorbar

%% Denoise the parent map
% Finaly we may apply filtering to the parent map to fill non indexed or
% not reconstructed pixels. To this end we first run grain reconstruction
% on the parent map

[parentGrains, parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',3*degree);

parentEBSD(parentGrains(parentGrains.grainSize<5)) = [];

[parentGrains, parentEBSD.grainId] = calcGrains(parentEBSD('indexed'),'angle',3*degree);
parentGrains = smooth(parentGrains,5);

plot(ebsd('indexed'),ebsd('indexed').orientations,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off

hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off

%%
% and then use the command <EBSD.smooth.html |smooth|> to fill the holes

F = halfQuadraticFilter;
parentEBSD = smooth(parentEBSD('indexed'),F,'fill',parentGrains);

plot(parentEBSD('Iron fcc'),parentEBSD('Iron fcc').orientations,'figSize','large')

hold on
plot(parentGrains.boundary,'lineWidth',2)
hold off
