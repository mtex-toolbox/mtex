function plotIPDF(ori,varargin)
% plot orientations into inverse pole figures
%
% Syntax
%   plotIPDF(ori,[r1,r2,r3])
%   plotIPDF(ori,[r1,r2,r3],'points',100)
%   plotIPDF(ori,[r1,r2,r3],'points','all')
%   plotIPDF(ori,[r1,r2,r3],'contourf')
%   plotIPDF(ori,[r1,r2,r3],'antipodal')
%   plotIPDF(ori,data,[r1,r2,r3])
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

[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% extract data
if check_option(varargin,'property')
  data = get_option(varargin,'property');
  data = reshape(data,[1,length(ori) numel(data)/length(ori)]);
elseif nargin > 1 && ~isa(varargin{1},'vector3d')
  [data,varargin] = extract_data(length(ori),varargin);
  data = reshape(data,[1,length(ori) numel(data)/length(ori)]);
else
  data = [];
end

% find inverse pole figure direction
r = [];
try r = getappdata(mtexFig.currentAxes,'inversePoleFigureDirection'); end
if isempty(r), r = varargin{1}; end
argin_check(r,'vector3d');

%  subsample if needed 
if (length(ori)*length(ori.CS)*length(ori.SS) > 100000 || check_option(varargin,'points')) ...
    && ~check_option(varargin,{'all','contourf','smooth','contour'})

  points = fix(get_option(varargin,'points',100000/length(ori.CS)/length(ori.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(ori)),' given orientations']);

  samples = discretesample(length(ori),points);
  ori = ori.subSet(samples);
  if ~isempty(data), data = data(:,samples,:); end

end

for ir = 1:length(r)

  if ir>1, mtexFig.nextAxis; end  
  
  % the crystal directions
  rSym = symmetrise(r(ir),ori.SS);
  h = ori(:) \ rSym;
  
  %  plot  
  [~,cax] = h.plot(repmat(data,1,length(rSym)),'symmetrised',...
    'fundamentalRegion','doNotDraw',varargin{:});
  if isNew, mtexTitle(cax(1),char(r(ir),'LaTeX')); end
  
  % plot annotations
  setappdata(cax,'inversePoleFigureDirection',r(ir));
  set(cax,'tag','ipdf');
  setappdata(cax,'CS',ori.CS);
  setappdata(cax,'SS',ori.SS);
        
  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% --------------- Tooltip function ------------------
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

ax = get(eventdata,'Target');
while ~ismember(ax,mtexFig.children), ax = get(ax,'parent'); end

sP = getappdata(ax,'sphericalPlot');
m = Miller(sP.proj.iproject(xp,yp),getappdata(ax,'CS'));
m = round(m);
txt = char(m,'tolerance',3*degree,'commasep');

end

end