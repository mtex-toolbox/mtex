%% Lists and Indexing
%
%%
% One key idea of MTEX is that variables may represent list of multiple
% objects of the same kind. To name just a few: a variable of type @EBSD
% represents a list of EBSD measurements, a variable of type @grain2d
% represents a list of grains and |grains.boundary| represents the list of
% all boundary segments of these grains. The next key idea is that a
% function applied to a list of something operates on each element
% individually and returns a list of results with the same size as the
% input list, e.g. 
% 
%   grains.area 
% 
% will return a list of grain areas for each grain in the list |grains|. In
% this section we will briefly explain the general syntax of working with
% lists or arrays as they are called by Matlab. For more details have a
% look at the
% <https://de.mathworks.com/help/matlab/learn_matlab/matrices-and-arrays.html
% Matlab documentation>.
%
%% Setting up a list
%

x = [1,2,3,4,5,6]

%%

x = 1:10

%%


y = x.^2


%% Direct Indexing
%

ind = [1,3,5]
y(ind)


%% Logical Indexing
%

% set up a condition that checks every element of x whether it is even or not
cond = iseven(x)

% extract on the elements of x that satisfy this condition
y(cond)


%%

