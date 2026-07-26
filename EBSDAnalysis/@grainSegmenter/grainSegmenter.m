classdef grainSegmenter < handle
% grain segmentation by agglomerative clustering with an MDL merge criterion
%
% This is an alternative to the threshold based reconstruction in
% <EBSD.calcGrains.html calcGrains>, aimed at maps where no threshold
% works: when the orientation noise per pixel is of the same size as the
% misorientation across the boundaries one is looking for, the within grain
% and the across boundary neighbour misorientation distributions overlap
% almost completely and no per pixel-pair criterion can separate them.
%
% The signal is still there, but only in aggregate. This class therefore
% does not classify pixel pairs at all. It starts from one region per pixel
% and repeatedly merges regions, deciding every merge by the minimum
% description length (MDL) principle: merge two regions whenever describing
% them by ONE orientation model is cheaper, in bits, than describing them
% by two. Cheaper means
%
%   cost = residual/(2 sigma^2)     % how badly the model fits the pixels
%        + regionCost + 3/2 log n   % what the model itself costs to store
%        + boundaryCost * length    % what its boundary costs to store
%
% A region is described either by one orientation or, when that earns its
% six extra parameters back, by an orientation plus a linear gradient of
% it. The gradient is the lattice curvature: without it a deformed grain
% has a residual that grows with its size and eventually gets cut in two.
%
% Because the residual of a region grows with its size while the cost of a
% model does not, the criterion automatically becomes more discriminating
% as regions grow: two single pixels are merged when they are within ~6
% sigma, two 2500 pixel regions only when their mean orientations agree to
% ~0.2 sigma. This is what lets boundaries far below the noise floor
% survive, and it needs no threshold from the user.
%
% Regions are merged in mutual-best-neighbour passes (Boruvka), not
% greedily: a merge is only carried out if each of the two regions is the
% other's best available partner. This matters, since merging is not
% reversible - a weak boundary is only crossed once everything better has
% been used up, by which time the regions are large enough to see it.
%
% Outliers are part of the model rather than something to filter out
% beforehand: a pixel that no model explains may instead be coded raw, for
% outlierCost, which caps how much a single bad pixel can ever influence a
% merge. Wild (misindexed) pixels are therefore absorbed into the
% surrounding grain instead of surviving as single pixel grains, and their
% orientation is set to NaN on output.
%
% This is a separate pipeline. It reuses the existing reconstruction chain
% only at the very end, and only read-only: the pixel labelling is handed
% to calcGrains through a gbcCustom criterion, so boundaries, polygons and
% the grain2d object are built by exactly the same code as always.
%
% Syntax
%   seg = grainSegmenter(ebsd)
%   seg.merge
%   [grains,ebsd] = seg.calcGrains
%
%   % all in one go
%   [grains,ebsd] = calcGrains(grainSegmenter(ebsd).merge)
%
%   % override the automatic noise estimate
%   seg = grainSegmenter(ebsd,'sigma',1.5*degree)
%
% Input
%  ebsd - @EBSD, gridded, currently square grids and a single indexed phase
%
% Options
%  sigma        - orientation noise per pixel (rad), estimated from second
%                 spatial differences if not given
%  regionCost   - description length of one region model (nats),
%                 default 3*log(maxAngle/sigma)
%  boundaryCost - description length of one boundary edge (nats),
%                 default 2. Measured on the benchmark: 1 to 3 all give
%                 the exact grain count, 5 starts merging the 1 degree
%                 boundaries away
%  outlierCost  - description length of one raw, unexplained pixel (nats),
%                 default regionCost
%  maxPass      - safety limit on the number of merge passes (default 1000)
%  minPixelLinear - smallest region a linear model may be fitted to
%                 (default 8)
%
% See also
% EBSD.calcGrains grainSegmenter.merge grainSegmenter.calcGrains

properties

  ebsd            % the (gridified) EBSD map being segmented

  sigma           % orientation noise per pixel, in rad
  regionCost      % description length of one region model, in nats
  boundaryCost    % description length of one boundary edge, in nats
  outlierCost     % description length of one unexplained pixel, in nats
  maxPass         % safety limit on the number of merge passes

  minPixelLinear  % smallest region a linear model may be fitted to

  id              % region label per pixel, 0 for not indexed pixels
  meanRotation    % mean orientation per region
  numPixel        % number of pixels per region
  modelOrder      % 3 for a constant, 9 for a linear model, per region
  isOutlier       % per pixel: not explained by its region's model

  history         % one row per merge pass: [numRegions numMerges]

end

properties (Hidden = true)
  CS              % crystal symmetry of the indexed phase
  ori             % orientations of the pixels taking part, in pixelId order
  pos             % [x y] of those pixels, centred on the map
  E               % pixel pairs (nEdges x 2) of the grid adjacency graph
  pixelId         % indices of the pixels taking part in the segmentation
  stat            % moment sums per region, see merge
  SSE             % residual of each region under its own model
  cost            % description length of each region, in nats
end

properties (Dependent = true)
  numRegions      % current number of regions
end

methods

  function seg = grainSegmenter(ebsd,varargin)

    ebsd = ebsd.gridify;

    if ~isa(ebsd,'EBSDsquare')
      error(['grainSegmenter currently supports square grids only. ' ...
        'Use calcGrains for hexagonal or ungridded data.']);
    end

    if numel(unique(ebsd.phaseId(ebsd.isIndexed))) > 1
      error('grainSegmenter currently supports a single indexed phase only.');
    end

    seg.ebsd = ebsd;

    % pixels that carry an orientation
    isValid = ebsd.isIndexed(:) & ~isnan(ebsd.rotations(:));
    seg.pixelId = find(isValid);

    if isempty(seg.pixelId), error('there is no indexed pixel to segment'); end

    % cache the data the merge passes work on - going through EBSD.subsref
    % once per pass would dominate the runtime
    csList  = ebsd.CSList;
    phaseId = ebsd.phaseId;
    rot     = ebsd.rotations;

    seg.CS  = csList(phaseId(seg.pixelId(1)));
    seg.ori = orientation(rot(seg.pixelId),seg.CS);

    % positions in physical units, centred so that the moment sums the
    % linear model is built from stay well conditioned
    p = ebsd.pos;
    px = p.x(seg.pixelId); py = p.y(seg.pixelId);
    seg.pos = [px - mean(px), py - mean(py)];

    % ------------------------------------------------------------ costs

    seg.sigma = get_option(varargin,'sigma',estimateNoise(ebsd));

    if seg.sigma <= 0
      error('the noise estimate is not positive - pass sigma explicitly');
    end

    % A region model is an orientation, stored to the precision that its
    % pixels justify. Storing it to precision sigma costs 3*log(Theta/sigma)
    % nats, where Theta is the size of the orientation space; the refinement
    % to sigma/sqrt(n) is the 3/2*log(n) term added in merge.
    Theta = maxAngle(seg.CS);
    seg.regionCost   = get_option(varargin,'regionCost',3*log(Theta/seg.sigma));
    seg.outlierCost  = get_option(varargin,'outlierCost',seg.regionCost);
    seg.boundaryCost = get_option(varargin,'boundaryCost',2);
    seg.maxPass        = get_option(varargin,'maxPass',1000);
    seg.minPixelLinear = get_option(varargin,'minPixelLinear',8);

    % ------------------------------------------- grid adjacency and seeds

    seg.E = gridEdges(size(ebsd),isValid);

    n = numel(seg.pixelId);
    seg.id = zeros(length(ebsd),1);
    seg.id(seg.pixelId) = 1:n;

    seg.meanRotation = seg.ori;
    seg.numPixel     = ones(n,1);
    seg.modelOrder   = 3*ones(n,1);
    seg.isOutlier    = false(length(ebsd),1);
    seg.history      = zeros(0,2);
    seg.stat         = [];

  end

  function n = get.numRegions(seg), n = numel(seg.numPixel); end

  function disp(seg,varargin)

    fprintf('\n grainSegmenter, %d regions from %d pixels\n\n', ...
      seg.numRegions,numel(seg.pixelId));
    fprintf('   noise sigma    : %.3f deg\n',seg.sigma/degree);
    fprintf('   region cost    : %.2f nat\n',seg.regionCost);
    fprintf('   boundary cost  : %.2f nat/edge\n',seg.boundaryCost);
    fprintf('   outlier cost   : %.2f nat\n',seg.outlierCost);
    fprintf('   outlier pixels : %.2f %%\n', ...
      100*nnz(seg.isOutlier)/numel(seg.pixelId));
    fprintf('   linear regions : %d of %d\n', ...
      nnz(seg.modelOrder > 3),seg.numRegions);
    fprintf('\n');

  end

end

end

% --------------------------------------------------------------- helpers

function E = gridEdges(sz,isValid)
% the 4-neighbourhood edges of a square grid, restricted to valid pixels

ind = reshape(1:prod(sz),sz);

E = [reshape(ind(1:end-1,:),[],1) reshape(ind(2:end,:),[],1); ...
     reshape(ind(:,1:end-1),[],1) reshape(ind(:,2:end),[],1)];

E = E(isValid(E(:,1)) & isValid(E(:,2)),:);

end
