function plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Syntax
% plotspatial(ebsd,'colocoding','ipdf')
% plotspatial(ebsd,'property','error')
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  property       - property used for coloring (default: orientation)
%  colocoding     - how to convert orientation to color
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%  GridType       - 'automatic' (default) / 'tetragonal' / 'hexagonal', or custom, requires flag 'unitcell'
%  GridResolution - specify the dimension of a unit cell, requires flag 'unitcell'
%  GridRotation   - rotation of a unit cell, requires flag 'unitcell'
%
%% Flags
%  unitcell - (default) plot spatial data by unit cells
%  voronoi  - plot spatial data through a voronoi decomposition
%  raster   - discretize on regular grid
%
%% See also
% EBSD/plot

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

prop = lower(get_option(varargin,'property','orientation'));

newMTEXplot;

%% compute colorcoding
if isa(prop,'double')
  d = prop;
  prop = 'user';
end;

switch prop
  case 'user'
  case 'orientation'
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    d = [];
    for i = 1:length(ebsd)
      d = [d;orientation2color(ebsd(i).orientations,cc,varargin{:})];
    end
  case 'phase'
    d = [];
    for i = 1:length(ebsd)
      if numel(ebsd(i).phase == 1)
        d = [d;ebsd(i).phase * ones(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      elseif numel(ebsd(i).phase == 0)
        d = [d;nan(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      else
        d = [d,ebsd.phase(:)]; %#ok<AGROW>
      end
    end
    colormap(hsv(max(d)+1));
%     co = get(gca,'colororder');
%     colormap(co(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('Unknown colorcoding!')
end


%% plot

x = get(ebsd,'x');
y = get(ebsd,'y');

try %if ~check_option(varargin,'raster')
  plotxyexact(x,y,d,varargin{:});
catch
  plotxy(x,y,d,varargin{:});
end

%dummy patch
[tx ty] = fixMTEXscreencoordinates(min(x), min(y),varargin{:});
patch('Vertices',[tx ty],'Faces',1,'FaceVertexCData',get(gca,'color'));

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
xy = vertcat(ebsd.xy);
[x y] = fixMTEXscreencoordinates(xy(:,1), xy(:,2));
q = get(ebsd,'quaternions');

dist = sqrt((x-xp).^2 + (y-yp).^2);
[dist ndx] = sort(dist);

ind = ndx(1); %select the nearest

% get phase
%% TODO!!!
phase = find(ind>cumsum([0,GridLength(ebsd)]),1,'last');
cs = get(ebsd(phase),'CS');

quat = double(q(ind));

txt =  {['Phase: ', num2str(phase), ' ' get(cs,'mineral'),'' ], ...
  ['quaternion (id: ', num2str(ind),') : ' ], ...
  ['    a = ',num2str(quat(1),2)], ...
  ['    b = ', num2str(quat(2),2)],...
  ['    c = ', num2str(quat(3),2)],...
  ['    d = ', num2str(quat(4),2) ]};

