function plotspatial(ebsd,varargin)
% spatial EBSD plot
%
%% Syntax
%  plotspatial(ebsd,'colocoding','ipdf')
%  plotspatial(ebsd,'property','error')
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  property   - property used for coloring (default: orientation)
%  colocoding - how to convert orientation to color
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also
% EBSD/plot

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

prop = lower(get_option(varargin,'property','orientation'));


%% compute colorcoding
if isa(prop,'double')
  d = prop;
  prop = 'user';
end;

switch prop
  case 'user'
  case 'orientation'
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    orientations = get(ebsd,'orientations');
    d = orientation2color(orientations,cc,varargin{:});
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
    co = get(gca,'colororder');
    colormap(co(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('Unknown colorcoding!')
end


%% plot 
newMTEXplot;

plotxy(get(ebsd,'x'),get(ebsd,'y'),d,varargin{:});
if strcmpi(prop,'orientation') && strcmpi(cc,'ipdf')
  [cs{1:length(orientations)}] = get(orientations,'CS');
  setappdata(gcf,'CS',cs)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcoding',...
    @(h,i) orientation2color(h,cc,'cs',cs{i},varargin{:}))
end
set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

set(gcf,'ResizeFcn',@fixMTEXplot);

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
phase = find(ind>cumsum([0,GridLength(ebsd)]),1,'last');
cs = get(ebsd(phase),'CS');

txt =  {['Phase: ', get(cs,'mineral'),'' ], ...
  ['quaternion (id: ', num2str(ind),') : ' ], ...
  ['    a = ',num2str(q(ind).a,2)], ...
  ['    b = ', num2str(q(ind).b,2)],...
  ['    c = ', num2str(q(ind).c,2)],...
  ['    d = ', num2str(q(ind).d,2) ]};

