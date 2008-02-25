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

for i = 1:length(ebsd)
  s(i) = sum(GridLength(ebsd(i).orientations)); %#ok<AGROW>
end
