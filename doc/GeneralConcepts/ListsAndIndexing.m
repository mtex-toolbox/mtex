%% Lists and Indexing
%
% Almost every MTEX variable is a list of objects of one kind. An @EBSD
% variable is a list of measurements, an @grain2d variable is a list of grains,
% and |grains.boundary| is a list of grain boundary segments. An @orientation
% variable commonly stores a list of orientations.
%
% There is no separate type for one grain. A single grain is an @grain2d list
% with length one.
%
% Two consequences account for most list operations in MTEX.
%
% * An elementwise function or property acts on every list element. It usually
% returns one result per element: |grains.area| gives one area per grain, and
% |ori.angle| gives one angle per orientation. Reduction functions such as
% |mean| are exceptions because they combine several elements into one result.
% Loops are therefore almost never needed for elementwise calculations.
% * Ordinary parentheses indexing selects elements as it does for a MATLAB
% array. The result is a list of the same kind, so an operation that accepts the
% complete list also accepts the selection.
%
% The diagram compares the two main forms of indexing. Position indices pick
% specified list entries in the requested order. A logical condition keeps the
% entries whose mask value is true.
%
% <<list-indexing.svg>>
%
% The sections that follow show the indexing itself on plain numbers, for
% clarity. The same two forms then apply unchanged to any MTEX list.

%% Make a list
%
% Square brackets create a list by placing values next to one another.

x = [1,2,3,4,5,6]

%%
% The colon operator is shorthand for a regularly spaced range. With no step
% specified, it uses a step of one.

x = 1:10

%% Apply an operation to every element
%
% MATLAB applies many arithmetic operations elementwise. The dot in |.^| means
% that every element of |x| is squared independently, rather than computing a
% matrix power.

y = x.^2

%% Select by position
%
% A list of positions selects those elements in the given order. Here, |ind|
% selects the first, third, and fifth squared values.

ind = [1,3,5]
y(ind)

%% Select by condition
%
% A condition evaluated for the complete list returns one logical value per
% element. A logical value is either true or false. It can be used as an index
% to retain only the corresponding true entries.

cond = iseven(x)
y(cond)

%%
% The condition tests which values in |x| are even. Using the same mask to
% index |y| returns their squares. This works because |x| and |y| have the same
% length and order.

%% Use the same pattern with MTEX objects
%
% Nearly every MTEX selection has the same form. For example,
% |grains(grains.area > 100)| selects grains with area greater than 100,
% |ebsd(ebsd.mad < 1)| selects measurements with a mean angular deviation below
% 1, and |gB(gB.misorientation.angle > 10*degree)| selects grain boundary
% segments with a misorientation angle greater than 10 degrees.
%
% In each expression, MTEX computes one property value per object. The
% comparison turns those values into a logical mask, and parentheses apply the
% mask to the original list.
%
% MTEX also provides two domain-specific selectors. A phase name selects all
% measurements of that phase, as in |ebsd('Forsterite')|. For spatial data, a
% position selects the object found there, as in |grains(x,y)|. See
% <SelectingGrains.html Selecting Grains> for spatial grain selections.

%% References
%
% * MathWorks, <https://www.mathworks.com/help/matlab/math/array-indexing.html
% Array Indexing>, _MATLAB documentation_. It defines positional and logical
% indexing and describes the array rules used on this page.

%% Next
%
% Continue with <GeneralConceptsConfiguration.html Configuration> to learn how
% session preferences control display, computation, and plotting defaults.
