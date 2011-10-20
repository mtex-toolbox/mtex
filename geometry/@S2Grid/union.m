function s = union(s,varargin)
% union of two S2Grids
%
%% Syntax
% 
%  s = union(s1,s2,..,sN)
%
%% Input
%  s1, s2, sN - @S2Grid
%% Output
%  s      - @S2Grid
%

s = horzcat(s,varargin{:});
