%% General Concepts
%
%%
% MTEX has a small number of habits that run through everything in it.
% Learning them once saves a great deal of confusion later, because they
% are assumed everywhere and explained almost nowhere else.
%
% The first and most important: *a variable holds many things, not one*. A
% |vector3d| is not a direction, it is a list of directions. An |EBSD|
% variable is a whole scan. A |grain2d| is every grain in a map. Operations
% apply to the whole list at once and return a whole list, so the loop you
% were about to write is almost always unnecessary and much slower than the
% expression that replaces it.
%
% The second follows from the first: *selecting a subset is how you narrow
% a question*. Indexing a list with a condition gives a shorter list of the
% same kind, which every later operation then accepts unchanged.

plottingConvention.default('y↑→x');

% one variable, five hundred directions
v = vector3d.rand(500);

% one condition, applied to all of them at once
isSteep = angle(v,vector3d.Z) < 30*degree;

plot(v(~isSteep),'upper','grid','MarkerSize',4,'MarkerFaceColor','gray')
hold on
plot(v(isSteep),'upper','MarkerSize',5,'MarkerFaceColor','red')
hold off

%%
% No loop appears anywhere in that. |angle| compared five hundred
% directions with one, and |v(isSteep)| kept the ones that passed. The same
% two steps select grains above a size, pixels of one phase, or boundaries
% above a misorientation.
%
%% Options, flags, and a trap
%
% Most MTEX commands take extra arguments in two forms. A *flag* is a bare
% word - |'silent'|, |'antipodal'|, |'contourf'| - and an *option* is a name
% followed by a value, as in |'halfwidth',10*degree|. They may be given in
% any order, after the required arguments.
%
% The trap is that a repeated option is not an error. If the same name
% appears twice, the *last* one wins, and nothing is reported. Building an
% argument list programmatically and appending a default at the end will
% therefore silently override what the caller asked for.
%
% A related and more common trap: a misspelt option name is simply not
% recognised, so it is ignored rather than rejected. The command then runs
% with its default and produces a plausible result. Copy option names
% rather than typing them.
%
%% Two kinds of extra data
%
% Objects carry additional data in two places that are easy to confuse, and
% the difference is about size rather than importance.
%
% A *property* has one value per element, so it is indexed and cut down
% alongside the object - the |mad| of each EBSD measurement, the |GOS| of
% each grain. An *option* is data about the whole object that does not have
% one value per element, such as the header a file was imported with, and it
% survives subsetting untouched.
%
% Putting scan-level information where per-element data belongs is a
% recurring mistake, and it shows up as a length mismatch the first time
% anyone takes a subset.
%
%% Where to start
%
% <MTEXScripts.html MTEX Scripts> and
% <ListsAndIndexing.html Lists and Indexing> cover everything above in
% detail, and are the two pages worth reading before writing any script of
% your own. <Properties.html Properties> covers the distinction just made.
%
% <GeneralConceptsOptions.html Options> is the full account of flags and
% options, and <GeneralConceptsConfiguration.html Configuration> covers the
% settings that persist across a session - default fonts, figure sizes,
% and the plotting convention that decides which specimen direction points
% where on screen. That last one changes every plot you make, so it is worth
% knowing where it is set.
%
% Two pages are for looking things up rather than reading through.
% <Glossary.html Glossary> defines the vocabulary used across the whole
% documentation, with the pairs that are easy to confuse placed side by
% side - misorientation and disorientation, halfwidth and bandwidth, hole
% and inclusion. <NotationAndConventions.html Notation and Conventions>
% states the choices MTEX makes that a result depends on: radians, the
% Bunge Euler convention, the direction an orientation acts in, planes
% against directions, and the crystal axis alignment. When a figure comes
% out mirrored or a number is wrong by a factor nobody can place, that page
% is where to look first.
%
% Two further pages are methods rather than mechanics.
% <DensityEstimation.html Density Estimation> is the step from a list of
% measurements to a smooth distribution, and
% <OptimalKernel.html Optimal Kernel> is about choosing how much to smooth -
% the halfwidth question that recurs in every density in MTEX.
% <ClusterDemo.html Clustering> groups orientations that lie close together,
% which is a different way of summarising a population from fitting a
% density to it.
%
%% Next
%
% With the habits above in place, <Tutorials.html Tutorials> is the fastest
% route into real work. <Plotting.html Plotting> covers how figures are put
% together, and the object types themselves begin at
% <Vectors.html Vectors>.
%
