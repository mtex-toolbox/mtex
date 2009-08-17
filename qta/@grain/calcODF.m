function grains = calcODF(grains,ebsd,varargin)
% function to calculate individual ODFs for each grain or an ODF based on the orientation of each grain
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD, specifiy to perform an ODF estimation based on original data
%
%% Output
%  grains  - @grain with odf as property
%  or odf  - @ODF if based on orientation of grains
%
%% See also
% ebsd/calcODF

if nargin>1 && isa(ebsd,'ebsd')
  [o grains] = grainfun(@(e) calcODF(e,varargin{:},'silent'), grains, ebsd,'property',get_option(varargin,'property','ODF'));
else
  if nargin>1, varargin = [{ebsd} varargin]; end
  grains = calcODF(toebsd(grains),varargin{:});
end

