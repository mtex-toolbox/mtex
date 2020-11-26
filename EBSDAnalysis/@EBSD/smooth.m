function [ebsd,filter] = smooth(ebsd,varargin)
% smooth spatial EBSD 
%
% Syntax
%
%   ebsd = smooth(ebsd)
%
%   F = halfQuadraticFilter
%   F.alpha = 2;
%   ebsd = smooth(ebsd, F, 'fill', grains)
%
% Input
%  ebsd   - @EBSD
%  F      - @EBSDFilters
%  grains - @grain2d if provided pixels at the boundary between grains are not filled
%
% Options
%  fill        - fill missing values (this is different then not indexed values!)
%  extrapolate - extrapolate up the the outer boundaries
%
% Example
%   mtexdata forsterite;
%   ebsd = ebsd('indexed');
%   % segment grains
%   [grains,ebsd.grainId] = calcGrains(ebsd);
%
%   % find largest grains
%   largeGrains = grains(grains.grainSize>800);
%   ebsd = ebsd(largeGrains(1));
%
%   figure
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold on
%   oM = ipfHSVKey(ebsd);
%   oM.inversePoleFigureDirection = mean(ebsd.orientations) * oM.whiteCenter;
%   oM.colorStretching = 50;
%   plot(ebsd,oM.orientation2color(ebsd.orientations))
%   hold off
%
%   ebsd_smoothed = smooth(ebsd);
%   plot(ebsd_smoothed('indexed'),oM.orientation2color(ebsd_smoothed('indexed').orientations))
%   hold on
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold off

% make a grided ebsd data set
ebsd = ebsd.gridify(varargin{:});

% set ebsd.quality to zero for all not indexed data
if isfield(ebsd.prop,'quality')
  ebsd.prop.quality(isnan(ebsd.rotations)) = 0;
else
  ebsd.prop.quality = ~isnan(ebsd.rotations);
end

% fill holes if needed
if check_option(varargin,'fill') || check_option(varargin,'extrapolate'), ebsd = fill(ebsd,varargin{:}); end

% read input
filter = getClass(varargin,'EBSDFilter',splineFilter);
filter.isHex = isa(ebsd,'EBSDhex');

% if possible smooth each grain seperately 
% otherwise each phase seperately
try
  grainId = ebsd.grainId;
catch
  grainId = reshape(ebsd.phaseId,size(ebsd));
end

% extract some locale variables
CSList = ebsd.CSList;
rot = ebsd.rotations;

[grainIds,pos] = unique(grainId(:));
pos = pos(~isnan(grainIds) & grainIds >0);
grainIds = grainIds(~isnan(grainIds) & grainIds >0).';
phaseIds = ebsd.phaseId(pos).';
%grainIds = grainIds(grainIds>0).';
progress(0,length(grainIds));

% find the largest grain
[~,m] = max(accumarray(grainId(grainId>0),1));

% and sort it first
if m>1
  phaseIds = [phaseIds(grainIds==m),phaseIds(grainIds~=m)];
  grainIds = [m,grainIds(grainIds~=m)];
end

% loop through all grains or phases
for id = 1:length(grainIds)

  progress(id,length(grainIds),' denoising EBSD data: ');
  
  % the values to be smoothed
  ind = grainId == grainIds(id); 

  % maybe there is nothing to do
  if ~any(ind(:)), continue; end

  % local coordinates in a local rectangular grid
  [irow,icol] = find(ind);
  minCol = min(icol); nCol = 1 + max(icol) - minCol;
  minRow = min(irow); 
  if filter.isHex, minRow = minRow - iseven(minRow); end
  nRow = 1 + max(irow) - minRow;
  indLocal = sub2ind([nRow,nCol],irow - minRow + 1,icol - minCol + 1);
    
  % skip small grains
  if nnz(ind)<5 || nRow < 2 || nCol < 2 || all(isnan(rot.a(ind)))
    continue, 
  end
    
  % generate orientation grid
  ori = orientation.nan(nRow,nCol,CSList{phaseIds(id)});
  ori(indLocal) = rot(ind);
  
  % extract quality
  quality = zeros(nRow,nCol);
  quality(indLocal) = ebsd.prop.quality(ind);
    
  % perform smoothing
  ori = filter.smooth(ori,quality);
      
  % store as rotations
  rot(ind) = ori(indLocal);
    
end

vdisp('',varargin{:});

% store to EBSD variable
ebsd.rotations = rot;

% set nan rotations to not indexed
ebsd.phaseId(isnan(rot(:))) = 1;

% remove nan data used to generate the grid
ebsd = ebsd.subSet(~isnan(ebsd.phaseId));

