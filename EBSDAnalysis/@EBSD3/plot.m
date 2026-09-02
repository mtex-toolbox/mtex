function vol = plot(ebsd,varargin)
% spatial EBSD plot
%
% Syntax
%
%   % colorize according to phase
%   plot(ebsd)
%
%   % colorize according to arbitrary value - here MAD
%   plot(ebsd,ebsd.mad)
%
%   % colorize according to orientation
%   plot(ebsd('phaseName'),ebsd('phaseName').orientation)
%
%   % colorize according to custom color
%   oM = ipfColorKey(ebsd('phaseName'))
%   color = oM.orientation2color(ebsd('phaseName').orientations);
%   plot(ebsd('phaseName'),color)
%
%   % specify the color directly and show in Legend
%   badMAD = ebsd.mad > 1;
%   plot(ebsd(badMAD),'faceColor','black,'DisplayName','bad values')
%
%   % plot a subregion
%   plot(ebsd,ebsd.orientation,'region',[xmin, xmax, ymin, ymax])
%
% Input
%  ebsd - @EBSD
%  color - length(ebsd) × 3 vector of RGB values
%
% Options
%  micronbar - 'on'/'off'
%  DisplayName - add a legend entry
%  region - [xmin, xmax, ymin, ymax] plotting region
%  
% Flags
%  points   - plot dots instead of unitcells
%  exact    - plot exact unitcells, even for large maps
%
% See also
% EBSDSpatialPlots

%
if isempty(ebsd), return; end

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')
    
  oM = ipfColorKey(varargin{1});
  varargin{1} = oM.orientation2color(varargin{1});
  
  if ~getMTEXpref('generatingHelpMode')
    disp('  I''m going to colorize the orientation data with the ');
    disp('  standard MTEX ipf colorkey. To view the colorkey do:');
    disp(' ');
    disp('  ipfKey = ipfColorKey(ori_variable_name)')
    disp('  plot(ipfKey)')
  end
end

% translate logical into numerical data
if nargin>1 && islogical(varargin{1}), varargin{1} = double(varargin{1}); end

% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
  varargin(1) = [];
    
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')

  sz = size(ebsd);
  assert(numel(sz)==3,'volume plotting requires the data in a 3d array, see @EBSD3square')

  % a scalar volume or an m x n x p x 3 rgb volume
  data = reshape(property,[sz,numel(property)/length(ebsd)]);

  isBad = ~reshape(ebsd.isIndexed,sz) | any(isnan(data),4);
  opt = {'AlphaData',double(~isBad)};

  if size(data,4) == 1
    opt = [opt,{'Colormap',getMTEXpref('defaultColorMap')}];
    fill = min(data(~isBad));
    if isempty(fill), fill = 0; end
  else
    fill = 1;
  end

  % slice planes have no per voxel transparency and volshow rejects NaN, so
  % unindexed voxels are painted in the background colour
  data(repmat(isBad,[1 1 1 size(data,4)])) = fill;

  % nearest neighbour keeps grain boundaries sharp
  viewer = viewer3d(BackgroundColor='w',BackgroundGradient='off');
  vol = optiondraw(volshow(data,opt{:},'Interpolation','nearest',...
    'RenderingStyle','SlicePlanes','Parent',viewer),varargin{:});

  set(viewer.Parent,'name','ebsd plot');
  
else % phase plot

  viewer = viewer3d(BackgroundColor='w',BackgroundGradient='off');

  % the base volume is only seen where no phase label covers it - white there
  value = double(~ebsd.isIndexed);
  label = uint8(reshape(ebsd.phaseId,size(ebsd)))-1;
  cmap = single(ebsd.colorList);
  vol = volshow(value,OverlayData = label,...
    RenderingStyle="SlicePlanes",Parent=viewer,...
    Interpolation = "nearest", OverlayAlpha = 1);
  %OverlayColormap=cmap
  %OverlayDisplayRange = [1,255],...
  %vol.OverlayColormap(1:size(ebsd.colorList,1),:) = cmap;
  %vol.OverlayAlpha = 1;
  %vol.OverlayAlphamap = ones(255,1); vol.OverlayAlphamap(1)=0;
  %vol.AlphaData = double(ebsd.isIndexed);
  %vol.OverlayRenderingStyle = "LabelOverlay";

  set(viewer.Parent,'name','phase plot');
  
end

if nargout == 0, clear("vol"); end
  
end


