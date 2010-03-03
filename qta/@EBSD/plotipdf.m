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
[ori,ind] = get(ebsd,'orientations','checkPhase',varargin{:});
cs = get(ori,'CS');
ss = get(ori,'SS');

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
if check_option(varargin,'colorcoding')
  cc = get_option(varargin,'colorcoding');  
  data = get(ebsd(ind),cc);  
else
  data = [];
end


%% get options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if numel(ori)*length(cs)*length(ss) > 100000 || check_option(varargin,'points')  
  points = get_option(varargin,'points',fix(100000/length(cs)/length(ss)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(numel(ori)),' given orientations']);
  ori = ori(discretesample(ones(1,numel(ori)),points));
end


%% plotting grid
h = @(i) reshape(inverse(quaternion(ori * cs)),[],1) * symmetrise(r(i),ss);
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(cs,varargin{:});
Sh = @(i) S2Grid(h(i),'MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});


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
