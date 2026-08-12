%% Grain Reconstruction by Markovian Clustering
%
%%
% Once the <GrainReconstructionAdvanced.html grain boundary criterion> has
% judged every pair of neighbouring pixels, the grains still have to be
% read off. By default they are the connected components of the pairs that
% were not separated - two pixels end up in the same grain whenever any
% chain of unseparated pairs leads from one to the other, however long and
% however thin.
%
% The Markovian clustering algorithm (MCL) reads them off differently. It
% simulates a random walk on the graph of pixels and alternates two steps:
% spreading, which lets the walk take one more step, and inflation, which
% raises every transition probability to a power |p| and renormalises,
% suppressing the unlikely steps in favour of the likely ones. Repeated,
% this drains the flow out of the weak connections and leaves it circulating
% within regions the walk rarely leaves - and those are the grains.
%
% It is selected by the option |'mcl'| with the inflation power and the
% number of iterations.

%% A criterion with something to say
%
% MCL works on the *weights* of the graph, so it needs a criterion that
% produces more than yes and no. With the default threshold criterion every
% weight is 0 or 1, the walk cannot distinguish a weak connection from a
% strong one, and MCL returns exactly the connected components it would
% have returned anyway - only much slower.
%
% We demonstrate this on the deformed austenite of the |EMSphinx| data set,
% the same one the <GrainReconstruction.html basic page> uses.

mtexdata EMSphinx silent

ebsd = ebsd('Iron fcc');
ebsd = ebsd(inpolygon(ebsd,[40 30 80 60]));

grains = calcGrains(ebsd,'angle',10*degree,'minPixel',10)

%%

grains = calcGrains(ebsd,'mcl',[1.2 4],'angle',10*degree,'minPixel',10)

%%
% The same 20 grains. What MCL needs is the soft threshold
% <gbcSoft.html |gbcSoft|>, whose connectivity falls off gradually around
% the threshold instead of jumping, and which is passed by the option
% |'soft'| as a pair |[angle width]|

grains = calcGrains(ebsd,'soft',[1 0.5]*degree,'minPixel',10)

%%
% On its own the soft criterion is still evaluated by connected components,
% and only shifts the threshold. Handing its weights to MCL changes the
% answer

grains = calcGrains(ebsd,'mcl',[1.2 4],'soft',[1 0.5]*degree,'minPixel',10)
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The low angle boundaries of the deformed grains are found, and the bent
% lattice inside them is not cut up - which is what a threshold of one
% degree would have done to it.

%% The inflation power
%
% Of the two parameters the inflation power is the one to turn. It sets how
% sharply the walk is forced onto its likely steps, so a larger value
% breaks the map into more and smaller clusters

for p = [1.1 1.4 1.8]

  grains = calcGrains(ebsd,'mcl',[p 4],'soft',[1 0.5]*degree,'minPixel',10);
  fprintf('inflation %.1f: %d grains\n',p,length(grains));

end

%%
% The second parameter, the number of iterations, is best left at its
% default of 4. Raising it changes the result very little and costs a great
% deal - the transition matrix fills in as the walk spreads, so on this map
% eight iterations take roughly ten times as long as four and return two
% grains more.

%% When to use it
%
% MCL is a global criterion: it does not ask about a pair of pixels in
% isolation but about how the whole map hangs together. On deformed
% material, where no single threshold angle works, that is exactly what is
% needed - but it is not the only way to get it, and
% <gbcFMC.gbcFMC.html |gbcFMC|> reaches a comparable segmentation of this
% same map in a fraction of the time and without a threshold angle at all.
% See <GrainReconstruction.html Grain Reconstruction> for that route.
%
% MCL remains the more flexible of the two: it takes the weights of
% *whatever* criterion produced them, including
% <gbcCustom.html |gbcCustom|> and criteria of your own, and clusters them
% without knowing what they mean.

%#ok<*NASGU>
%#ok<*NOPTS>
