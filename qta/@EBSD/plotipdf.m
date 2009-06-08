function plotipdf(ebsd,r,varargin)
% plot inverse pole figures
%
%% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
%% Options
%  RESOLUTION - resolution of the plots
%  
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% make new plot
[grid,ind] = getgrid(ebsd,'checkPhase',varargin{:});
cs = get(grid,'CS');
ss = get(grid,'SS');

if newMTEXplot('ensureTag','ipdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(r,{'vector3d'});
else
  if ~isa(r,'vector3d')
    varargin = {r,varargin{:}};
  end
  r = getappdata(gcf,'r');
  o = getappdata(gcf,'options');
  if ~isempty(o), varargin = {o{:},varargin{:}};end
end

%% colorcoding
if check_option(varargin,'colorcoding')
  cc = get_option(varargin,'colorcoding');  
  data = get(ebsd(ind),cc);  
else
  data = [];
end


%% get options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if sum(GridLength(grid))*length(cs)*length(ss) > 100000 || check_option(varargin,'points')  
  points = get_option(varargin,'points',fix(100000/length(cs)/length(ss)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(sum(GridLength(grid))),' given orientations']);
  grid = subsample(grid,points);
end


%% plotting grid
h = @(i) reshape(inverse(quaternion(grid * cs)),[],1) * symetriceVec(ss,r(i));
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(cs,varargin{:});
Sh = @(i) S2Grid(h(i),'MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,varargin{:});


%% plot
multiplot(@(i) Sh(i),@(i) data,length(r),...
  'ANOTATION',@(i) r(i),...
  'appdata',@(i) {{'r',r(i)}},...
  'dynamicMarkerSize', varargin{:});

setappdata(gcf,'r',r);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
set(gcf,'Name',['Inverse Pole figures of "',inputname(1),'"']);
set(gcf,'Tag','ipdf');
