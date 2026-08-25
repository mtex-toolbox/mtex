%% Lists and Indexing
%
%%
% Almost every MTEX variable is a list. An @EBSD variable is a list of
% measurements, a @grain2d a list of grains, |grains.boundary| a list of
% boundary segments, an @orientation usually a list of orientations. There
% is no separate "one grain" type - a single grain is a list of length one.
%
% Two consequences follow, and together they are most of what one needs to
% know to write MTEX code.
%
% * A function applied to a list works on every element and returns a list
% of the same size. |grains.area| gives one area per grain, |ori.angle| one
% angle per orientation. Loops are almost never needed.
% * Selecting elements is indexing, and it works exactly as it does for a
% MATLAB array. The result is a list of the same kind, so anything that
% works on the whole works on the selection.
%
% The rest of this page is the indexing itself, on plain numbers for
% clarity. The <https://de.mathworks.com/help/matlab/learn_matlab/matrices-and-arrays.html
% MATLAB documentation> covers it in more depth.

%% Making a list

x = [1,2,3,4,5,6]

%%
% and the shorthand for a range:

x = 1:10

%%
% Arithmetic applies elementwise. Note the dot in |.^| - it says "each
% element" rather than "the matrix power".

y = x.^2

%% Indexing by position
%
% A list of positions selects those elements, in that order.

ind = [1,3,5]
y(ind)

%% Indexing by condition
%
% More useful in practice: a condition evaluated over the whole list gives a
% list of true and false, and that selects the elements where it is true.

% set up a condition that checks every element of x whether it is even or not
cond = iseven(x)

% extract on the elements of x that satisfy this condition
y(cond)

%%
% This is the form nearly every selection in MTEX takes -
% |grains(grains.area > 100)|, |ebsd(ebsd.mad < 1)|,
% |gB(gB.misorientation.angle > 10*degree)|. The condition is computed on
% one list and used to index another, which only works because both have the
% same length and the same order.
%
% Two MTEX specific forms are worth knowing beside these. A phase name
% selects the elements of that phase, |ebsd('Forsterite')|, and for spatial
% data a position selects what is there, |grains(x,y)| - see
% <SelectingGrains.html Selecting Grains>.
