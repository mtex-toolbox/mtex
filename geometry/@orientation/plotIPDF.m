function plotIPDF(o,r,varargin)
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

mtexFig = mtexFigure('ensureTag','ipdf',...
  'ensureAppdata',{{'CS',o.CS}});

if isempty(mtexFig.children)
  argin_check(r,'vector3d');
else
  if ~isa(r,'vector3d')
    varargin = [{r},varargin];
  end
  r = getappdata(gcf,'r');
end

% colorcoding 1
data = get_option(varargin,'property',[]);

% --------------- subsample if needed ------------------------
if (length(o)*length(o.CS)*length(o.SS) > 100000 || check_option(varargin,'points')) ...
    && ~check_option(varargin,{'all','contourf','smooth','contour'})

  points = fix(get_option(varargin,'points',100000/length(o.CS)/length(o.SS)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);

  samples = discretesample(ones(1,length(o)),points);
  o= o.subSet(samples);
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

% ------------------ plot ------------------------------

% predefines axes?
paxes = get_option(varargin,'parent');

for i = 1:length(r)

  % which axes
  if isempty(paxes), ax = mtexFig.nextAxis; else ax = paxes(i); end
  
  % the crystal directions
  rSym = symmetrise(r(i),o.SS);
  h = o(:) \ rSym;
  
  %  plot  
  h.plot(repmat(data(:),1,length(rSym)),'scatter','symmetrised',...
    'fundamentalRegion','TR',char(r(i),getMTEXpref('textInterpreter')),...
    'parent',ax,varargin{:});
  
  % TODO: unifyMarkerSize

end

if isempty(paxes)
  setappdata(gcf,'r',r);
  setappdata(gcf,'SS',o.SS);
  setappdata(gcf,'CS',o.CS);
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  set(gcf,'Name',['Inverse Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'Tag','ipdf');

  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});

  datacursormode on;
  mtexFig.drawNow;

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
