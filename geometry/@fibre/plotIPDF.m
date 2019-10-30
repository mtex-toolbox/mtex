function plotIPDF(f,varargin)
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
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% maybe we should call this function with the option add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((((ishold(mtexFig.gca) && nargin > 1 && isa(varargin{1},'vector3d') && length(varargin{1})>1))) || check_option(varargin,'add2all'))
  plot(ori,varargin{:},'add2all');
  return
end

% find inverse pole figure direction
r = [];
try r = getappdata(mtexFig.currentAxes,'inversePoleFigureDirection'); end
if isempty(r), r = varargin{1}; end
argin_check(r,'vector3d');

for ir = 1:length(r)

  if ir>1, mtexFig.nextAxis; end

  % the crystal directions
  h = f.orientation \ r(ir);

  if ~check_option(varargin,{'complete','noSymmetry'})
    h = h.project2FundamentalRegion;
  end

  %  plot
  [~,cax] = h.line('fundamentalRegion','doNotDraw',varargin{:});

  if isNew, mtexTitle(cax(1),char(r(ir),'LaTeX')); end

  setappdata(cax,'inversePoleFigureDirection',r(ir));
  set(cax,'tag','ipdf');
  setappdata(cax,'CS',f.CS);
  setappdata(cax,'SS',f.SS);

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% --------------- Tooltip function ------------------
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

rho = atan2(yp,xp);
rqr = xp^2 + yp^2;
theta = acos(1-rqr/2);

m = Miller(vector3d.byPolar(theta,rho),getappdata(gcf,'CS'));
m = round(m);
txt = char(m,'tolerance',3*degree,'commasep');
