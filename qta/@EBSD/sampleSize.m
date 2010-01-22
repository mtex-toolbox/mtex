function s = sampleSize(ebsd)
% vector of sizes ebsd data sets
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  l - number of orientations per ebsd data set
%
%% See also
% EBSD_index

s = arrayfun(@ (i) numel(ebsd(i).orientations),1:numel(ebsd),...
  'uniformoutput',true);

