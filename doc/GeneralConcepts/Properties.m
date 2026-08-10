%% Properties
%
%%
% Most list like MTEX classes - <EBSD.EBSD.html EBSD>,
% <grain2d.grain2d.html grain2d>, <grainBoundary.grainBoundary.html
% grainBoundary>, <PoleFigure.PoleFigure.html PoleFigure> - carry, besides
% their orientations and their geometry, an open ended list of *properties*.
% A property is nothing but a numeric array that has one entry for every
% element of the list, and that is carried along whenever the list is
% indexed, subsetted, concatenated or sorted. This is what makes it
% possible to write |ebsd(condition).mad| and get exactly the MAD values of
% the selected pixels.
%
%% Which properties are there
%
% Which properties an object has depends on where its data came from. An
% EBSD file usually contributes at least the confidence index and the
% error of the fit. All properties are collected in the struct |prop|

mtexdata forsterite silent

ebsd.prop

%%
% and each of them is at the same time accessible as if it was a regular
% field of the object

ebsd.mad(1:5)

%%
% The single most important thing about a property is that it is in
% lockstep with the list. Selecting a subset selects the corresponding
% property values

ebsdSub = ebsd(ebsd.mad < 1);

length(ebsdSub)

%%

length(ebsdSub.mad)

%% Adding your own properties
%
% A new property is created by assigning to a field of |prop|. Note that
% the |prop| is required here - writing |ebsd.myQuality = ...| directly
% would try to set a class property of |EBSD| and fail, since MTEX has no
% way of telling a typo from a new property.

ebsd.prop.myQuality = 1 ./ (1 + ebsd.mad);

ebsd.prop

%%
% From now on |myQuality| behaves exactly like any built in property - it
% can be read and overwritten as |ebsd.myQuality| without the |prop|, and
% it survives indexing

ebsd('Forsterite').myQuality(1:5)

%%
% and it can be used for plotting

plot(ebsd('Forsterite'),ebsd('Forsterite').myQuality)
mtexColorbar('title','my quality')

%%
% A property does not have to be numeric. Anything that supports indexing
% works, for instance a <vector3d.vector3d.html vector3d> per pixel - here
% the specimen direction of the crystallographic $c$ axis.

ebsdFo = ebsd('Forsterite');
ebsdFo.prop.myAxis = ebsdFo.orientations .* Miller(0,0,1,ebsdFo.CS);

ebsdFo.prop

%% Properties of grains
%
% Grains work the same way. In addition to the properties MTEX computes
% itself, such as |GOS| or |meanRotation|, one can attach anything that has
% one value per grain.

grains = calcGrains(ebsd('indexed'),'angle',10*degree);

grains.prop

%%
% A typical use is to store a derived quantity so that it can be plotted
% and selected on later without recomputing it

grains.prop.myRatio = grains.longAxis.norm ./ grains.shortAxis.norm;

plot(grains('Forsterite'),grains('Forsterite').myRatio)
setColorRange([1 5])
mtexColorbar('title','aspect ratio')

%%
% One caveat: MTEX does not verify that the value you assign has the right
% length. A property that is too short is accepted silently and only fails
% later, when the object is indexed

grains.prop.nonsense = [1 2 3];

try
  grains(1:5).nonsense
catch e
  disp(e.message)
end

%% Where properties come from
%
% Technically all of this is implemented by the class |dynProp|
% (|tools/dynProp.m|), from which |EBSD|, |grain2d| and the other list
% classes inherit. It provides the |prop| struct together with overloaded
% indexing, concatenation and subsetting, so that a new property
% automatically takes part in all of them. The
% <EBSDImport.html import interfaces> use exactly the same mechanism -
% every column of a |.ang| or |.ctf| file that MTEX does not recognize as
% position, phase or orientation ends up as a property.

%#ok<*NOPTS>
