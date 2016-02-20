function  bS = boundarySize(grains,varargin)
% number of boundary segment
%
% Input
%  grains - @grain2d
%
% Output
%  bS - number of boundary segments
%
% Syntax
%   peri = grains.boundarySize
%


% ignore holes
bS = cellfun(@(x) length(x) - nnz(x(2:end) == x(1)),grains.poly);
