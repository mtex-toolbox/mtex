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
%  color - length(ebsd) x 3 vector of RGB values
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
% Example
%
%   mtexdata forsterite
%   plot(ebsd)
%
%   % colorize according to orientations
%   plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)
%
%   % colorize according to MAD
%   plot(ebsd,ebsd.mad,'micronbar','off')
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
    
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')
  
  warning('not yet implemented')

  
else % phase plot

  viewer = viewer3d;

  value = double(ebsd.isIndexed);
  label = uint8(reshape(ebsd.phaseId,size(ebsd)))-1;
  cmap = single(ebsd.colorList);
  vol = volshow(value,OverlayData = label,...
    RenderingStyle="SlicePlanes",Parent=viewer,...
    OverlayAlpha = 1);
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


