function h = plotspatial(ebsd,varargin)
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
%   loadaachen
%   plot(ebsd,'colorcoding','hkl')
%
%   plot(ebsd,'property','phase')
%
%   plot(ebsd,'property','mad')
%
%% See also
% EBSD/plot

% restrict to a given phase or region
ebsd = copy(ebsd,varargin{:});


% get coordinates
xy = get(ebsd,'X');

if ~isempty(xy) && size(xy,2) == 3
  slice3(ebsd,varargin{:});
  return
end

%%

% which property to plot
prop = lower(get_option(varargin,'property','orientation'));

%% plot property phase
if strcmp(prop,'phase') && ~check_option(varargin,'FaceColor')
  
  % colormap for phase plot
  cmap = get_mtex_option('PhaseColorMap');
  
  % get all phases
  phases = get(ebsd,'phase');
  
  varargin = set_option(varargin,'property','none');
  % plot all phases separately
  washold = ishold;
  hold all;
  for i = 1:length(phases)
    faceColor = cmap(1+mod(phases(i)-1,length(cmap)),:);
    plotspatial(ebsd,varargin{:},'FaceColor',faceColor,'phase',phases(i));
  end
  if ~washold, hold off;end
  
  % add a legend
  [minerals{1:length(phases)}] = get(ebsd,'mineral');
  legend(minerals);
  
  return
end

%% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% clear up figure
newMTEXplot;

%% compute colorcoding
if isa(prop,'double')
  d = prop;
  prop = 'user';
else % default value
  d = [];
end;

switch prop
  case 'user'
  case 'orientation'
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    for i = 1:length(ebsd)
      d = [d;orientation2color(ebsd(i).orientations,cc,varargin{:})]; %#ok<AGROW>
    end
  case 'none'
  case 'phase'
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('Unknown colorcoding!')
end


%% plot

try %if ~check_option(varargin,'raster')
  h = plotxyexact(xy,d,ebsd(1).unitCell,varargin{:});
catch %#ok<CTCH>
  h = plotxy(xy,d,varargin{:});
end

% set appdata
if strcmpi(prop,'orientation') %&& strcmpi(cc,'ipdf')
  [cs{1:length(ebsd)}] = get(ebsd,'CS');
  setappdata(gcf,'CS',cs)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',cc);
end
set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

fixMTEXscreencoordinates('axis'); %due to axis;
set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});

%% set data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'SnapToDataVertex','off')
set(dcm_obj,'UpdateFcn',{@tooltip,ebsd});

if check_option(varargin,'cursor'), datacursormode on;end


%% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

xy = vertcat(ebsd.X);
[x y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2));

delta = prod(diff([min(xy);max(xy)]))./(size(xy,1)/2);

candits = find(~(xp-delta > x | xp+delta < x | yp-delta > y | yp+delta < y));

if ~isempty(candits)
  dist = sqrt( (xp-x(candits)).^2 + (yp-y(candits)).^2);
  [dist ind] = sort(dist);
  candits = candits(ind);
  
  nd = candits(1);
  
  sz = sampleSize(ebsd);
  csz = cumsum([0,sz]);
  phase = find(nd>csz,1,'last');
  pos = nd-csz(phase);
  o = ebsd(phase).orientations(pos);
  
  txt = {['Phase: ', num2str(ebsd(phase).phase), ' ' get(get(o,'CS'),'mineral'),'' ], ...
    ['index:' num2str(pos)],...
    [char(o)]};
  
else
  
  txt = 'no data';
end



