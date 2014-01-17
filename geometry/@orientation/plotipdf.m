function plotipdf(o,r,varargin)
% plot inverse pole figures
%
% Input
%  ebsd - @EBSD
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%  property   - user defined colorcoding
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% ---------------------- where to plot -----------------------
[ax,o,r,varargin] = getAxHandle(o,r,varargin{:});

cs = o.CS;
ss = o.SS;

if ~isempty(ax) || newMTEXplot('ensureTag','ipdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(r,{'vector3d'});
  annotations  = {'TR',@(i) char(r(i),getMTEXpref('textInterpreter'))};
else
  if ~isa(r,'vector3d')
    varargin = [{r},varargin];
  end
  r = getappdata(gcf,'r');
  annotations  = {};
end

% colorcoding 1
data = get_option(varargin,'property',[]);

% --------------- subsample if needed ------------------------

if length(o)*length(cs)*length(ss) > 100000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',100000/length(cs)/length(ss)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);

  samples = discretesample(ones(1,length(o)),points);
  o= subsref(o,samples);
  if ~isempty(data), data = data(samples); end

end

% colorcoding 2
if check_option(varargin,'colorcoding')
  colorcoding = lower(get_option(varargin,'colorcoding','angle'));
  data = orientation2color(o,colorcoding,varargin{:});
  
  % convert RGB to ind
  if numel(data) == 3*length(o)  
    [data, map] = rgb2ind(reshape(data,[],1,3), 0.03,'nodither');
    set(gcf,'colormap',map);    
  end
  
end

%

data = @(i) repmat(data(:),1,length(symmetrise(r(i),ss)));

% plot
multiplot(ax{:},length(r),...
  @(i) inv(o(:)) * symmetrise(r(i),ss),data,...
  'scatter','FundamentalRegion','unifyMarkerSize',...
  annotations{:},varargin{:});

if isempty(ax)
  setappdata(gcf,'r',r);
  setappdata(gcf,'SS',ss);
  setappdata(gcf,'CS',cs);
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  set(gcf,'Name',['Inverse Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'Tag','ipdf');


  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});

  datacursormode on;
end


% --------------- Tooltip function ------------------
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

rho = atan2(yp,xp);
rqr = xp^2 + yp^2;
theta = acos(1-rqr/2);

m = Miller(vector3d('polar',theta,rho),getappdata(gcf,'CS'));
m = round(m);
txt = char(m,'tolerance',3*degree,'commasep');
