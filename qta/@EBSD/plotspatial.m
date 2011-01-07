function h = plotspatial(ebsd,varargin)
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

% colormap for phase plot
cmap = [0 0 1; 1 0 0; 0 1 0; 1 1 0; 1 0 1; 0 1 1];

% which property to plot
prop = lower(get_option(varargin,'property','orientation'));

if strcmp(prop,'phase') && ~check_option(varargin,'FaceColor')
  
  % get all phases
  phases = get(ebsd,'phase');

  varargin = set_option(varargin,'property','none');
  % plot all phases separately
  washold = ishold;
  hold all;
  for i = 1:length(phases)    
    plotspatial(ebsd,'phase',phases(i),varargin{:},'FaceColor',cmap(i,:));
  end
  if ~washold, hold off;end
  
  % add a legend
  [minerals{1:length(phases)}] = get(ebsd,'mineral');    
  legend(minerals);
  
  return
end

%restrict to a given phase
if check_option(varargin,'phase') && ~strcmpi(prop,'phase') 
	ebsd(~ismember([ebsd.phase],get_option(varargin,'phase'))) = [];
end

% default plot options
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
%     for i = 1:length(ebsd)
%       if numel(ebsd(i).phase == 1)
%         d = [d;ebsd(i).phase * ones(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
%       elseif numel(ebsd(i).phase == 0)
%         d = [d;nan(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
%       else
%         d = [d,ebsd(i).phase(:)]; %#ok<AGROW>
%       end
%     end
%     %phases = unique(d);
%     colormap(hsv(1+max(d)-min(d)));
%     %co = get(gca,'colororder');
%     %colormap(cmap(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('Unknown colorcoding!')
end


%% plot

xy = get(ebsd,'X');
% y = get(ebsd,'y');

if check_option(varargin,'region')
  region = get_option(varargin,'region');
  ind = xy(:,1) > region(1) & xy(:,2) > region(2) ...
    & xy(:,1) < region(3) & xy(:,2) < region(4);
  xy = xy(ind,:);
  if size(d,2) == 3
    d = d(ind,:);
  elseif ~isempty(d)
    d = d(ind);
  end
end

try %if ~check_option(varargin,'raster')
  h = plotxyexact(xy,d,ebsd(1).unitCell,varargin{:});
catch %#ok<CTCH>
  h = plotxy(xy,d,varargin{:});
end

%dummy patch
% [tx ty] = fixMTEXscreencoordinates(min(x), min(y),varargin{:});
% patch('Vertices',[tx ty],'Faces',1,'FaceVertexCData',get(gca,'color'));

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



