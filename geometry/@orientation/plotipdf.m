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
  getpref('mtex','defaultPlotOptions'));

if numel(o)*length(cs)*length(ss) > 100000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',100000/length(cs)/length(ss)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(numel(o)),' given orientations']);

  samples = discretesample(ones(1,numel(o)),points);
  o.rotation = o.rotation(samples);
  if ~isempty(data), data = data(samples); end

end

  
%% plot
multiplot(numel(r),...
  @(i) inverse(o(:)) * symmetrise(r(i),ss),data,...
  'scatter','dynamicMarkerSize','FundamentalRegion',...
  'TR',@(i) char(r(i),'LaTex'),...
  varargin{:});


setappdata(gcf,'r',r);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
set(gcf,'Name',['Inverse Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
set(gcf,'Tag','ipdf');


%% set data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'SnapToDataVertex','off')
set(dcm_obj,'UpdateFcn',{@tooltip});

datacursormode on;


%% Tooltip function
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

rho = atan2(yp,xp);
rqr = xp^2 + yp^2;
theta = acos(1-rqr/2);

m = Miller(vector3d('polar',theta,rho),getappdata(gcf,'CS'));

txt = char(m,'tolerance',3*degree);

