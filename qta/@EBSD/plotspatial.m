function varargout = plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  property       - property used for coloring (default: orientation), other properties may be
%     |'phase'| for achieving a spatial phase map, or an properity field of the ebsd
%     data set, e.g. |'bands'|, |'bc'|, |'mad'|.
%
%  colocoding     - [[orientation2color.html,colorize orientation]] according a
%    colormap after inverse PoleFigure
%
%    * |'ipdf'|
%    * |'hkl'|
%
%    other color codings
%
%    * |'angle'|
%    * |'bunge'|, |'bunge2'|, |'euler'|
%    * |'sigma'|
%    * |'rodrigues'|
%
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]] when
%     using inverse
%     PoleFigure colorization
%
%  GridType       - requires param |'unitcell'|
%
%    * |'automatic'| (default)
%    * |'tetragonal'|
%    * |'hexagonal'|
%
%    or custom
%
%  GridResolution - specify the dimension of a unit cell, requires param |'unitcell'|
%  GridRotation   - rotation of a unit cell, requires option |'unitcell'|
%
%% Flags
%  unitcell - (default) plot spatial data by unit cells
%  voronoi  - plot spatial data through a voronoi decomposition
%  raster   - discretize on regular grid
%% Example
% plot a EBSD data set spatially with custom colorcoding
%
%   mtexdata aachen
%   plot(ebsd,'colorcoding','hkl')
%
%   plot(ebsd,'property','phase')
%
%   plot(ebsd,'property','mad')
%
%% See also
% EBSD/plot

% restrict to a given phase or region
%ebsd = copy(ebsd,varargin{:});

if ~numel(ebsd), return, end

%% check for 3d data
if isfield(ebsd.options,'z')
  slice3(ebsd,varargin{:});
  return
end

%% get spatial coordinates and colorcoding

x_D = [ebsd.options.x ebsd.options.y];

% seperate measurements per phase
nphase = numel(ebsd.phaseMap);
X = cell(1,nphase); d = cell(1,nphase);

for k=1:nphase
  iP = ebsd.phase==k;
  X{k} = x_D(iP,:);
  [d{k},property] = calcColorCode(ebsd,iP,varargin{:});
end

%% default plot options

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% clear up figure
newMTEXplot;

isPhase = find(~cellfun('isempty',X));

for k=1:numel(isPhase)
  h(k) = plotUnitCells(X{isPhase(k)},d{isPhase(k)},ebsd.unitCell,varargin{:});
end

fixMTEXplot;

% make legend
minerals = get(ebsd,'minerals');
legend(h,minerals(isPhase));
legend('off')

if strcmpi(property,'phase'),
  % phase colormap
  set(gca,'CLim',[min(ebsd.phaseMap) max(ebsd.phaseMap)]);
  colormap(hsv(numel(ebsd.phaseMap)));
  
  legend('show');
end

% set appdata
if strcmpi(property,'orientation') %&& strcmpi(cc,'ipdf')
  setappdata(gcf,'CS',ebsd.CS)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',lower(get_option(varargin,'colorcoding','ipdf')));
end

set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

%
fixMTEXscreencoordinates('axis'); %due to axis;
set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});

if ~isOctave()
  %% set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});

  if check_option(varargin,'cursor'), datacursormode on;end
if nargout>0, varargout{1}=h; end

%% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

[x y] = fixMTEXscreencoordinates(ebsd.options.x,ebsd.options.y);

delta = 1.5*mean(sqrt(sum(diff(ebsd.unitCell).^2,2)));

candits = find(~(xp-delta > x | xp+delta < x | yp-delta > y | yp+delta < y));

if ~isempty(candits)
  
  dist = sqrt( (xp-x(candits)).^2 + (yp-y(candits)).^2);
  [dist ind] = min(dist);
  candits = candits(ind);
  
  phase = ebsd.phase(candits);
  o = orientation(ebsd.rotations(candits),ebsd.CS{phase},ebsd.SS);
  
  minerals = get(ebsd,'minerals');
  minerals{phase}
  txt{1} = ['Phase: ', minerals{phase},'' ];
  
  if ~ischar(ebsd.CS{phase}), ...
      txt{2} = ['Orientation: ' char(o)];
  end
  
else
  txt = 'no data';
end

