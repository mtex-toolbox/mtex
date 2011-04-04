function plotipdf(o,r,varargin)
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
%  COMPLETE - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% make new plot

cs = o.CS;
ss = o.SS;

if newMTEXplot('ensureTag','ipdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(r,{'vector3d'});
else
  if ~isa(r,'vector3d')
    varargin = {r,varargin{:}};
  end
  r = getappdata(gcf,'r');
  options = getappdata(gcf,'options');
  if ~isempty(options), varargin = {options{:},varargin{:}};end
end

%% colorcoding
data = get_option(varargin,'property',[]);

%% get options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if numel(o)*length(cs)*length(ss) > 100000 || check_option(varargin,'points')  
  points = fix(get_option(varargin,'points',100000/length(cs)/length(ss)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(numel(o)),' given orientations']);
  
  samples = discretesample(ones(1,numel(o)),points);
  o.rotation = o.rotation(samples);
  if ~isempty(data),
    data = data(samples); end
 
end

%% plotting grid

h = @(i) reshape(inverse(quaternion(o * cs)),[],1) * symmetrise(r(i),ss);
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(cs,varargin{:});
Sh = @(i) S2Grid(h(i),'MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});

if ~isempty(data)
  data = repmat(data,numel(o.CS),1);
  Dh  = @(i) (reshape(double(h(i)),[],3));  
  DSh = @(i) (reshape(double(Sh(i)),[],3));
  datar = @(i)  data(ismember(DSh(i),Dh(i),'rows'));
else
  datar = @(i)[];
end

%% plot
multiplot(@(i) Sh(i), datar ,length(r),...
  'ANOTATION',@(i) r(i),...
  'appdata',@(i) {{'r',r(i)}},...
  'dynamicMarkerSize', varargin{:});

setappdata(gcf,'r',r);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
set(gcf,'Name',['Inverse Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
set(gcf,'Tag','ipdf');
