function l = length(gB)
% number of boundary segments
%
% Description
% The number of segments the grain boundary consists of. Note that this is
% a plain count of segments - the summed up geometric length of all
% segments is computed by <grainBoundary.segLength.html |segLength|>.
%
% Syntax
%   n = length(gB)
%
% Input
%  gB - @grainBoundary
%
% Output
%  n - number of boundary segments
%
% See also
% grainBoundary/segLength

l = size(gB,1);
