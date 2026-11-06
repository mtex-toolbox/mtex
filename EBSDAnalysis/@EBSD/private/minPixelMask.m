function removed = minPixelMask(ebsd,gbc,varargin)
% pixels of undersized indexed grains on the grid neighbourhood, for 'minPixelMethod','grid'
%
% Connected components on the stencil plus the diagonals, cheaper than a
% decomposition but blind to the gaps the closing bridges: a grain joined only
% across one is sized in parts and may be culled. Without the option nothing is
% removed here; calcGrains culls what comes out of the decomposition below
% minPixel and decomposes again.
%
% Input
%  ebsd - @EBSD (gridified)
%  gbc  - grain boundary criterion
%
% Output
%  removed - nEbsd × 1 logical, true for undersized indexed pixels

removed = false(length(ebsd),1);
if get_option(varargin,'minPixel',1) <= 1 || ...
    ~strcmpi(get_option(varargin,'minPixelMethod',''),'grid'), return; end

gid = gridComponents(ebsd,gbc,varargin{:});       % grain id per pixel, 0 = none
np = accumarray(gid(gid>0), 1, [max(gid) 1]);     % pixels per grain
sz = zeros(length(ebsd),1);
sz(gid>0) = np(gid(gid>0));                       % grain size seen by each pixel
removed = ebsd.isIndexed(:) & sz < get_option(varargin,'minPixel',1);

end
