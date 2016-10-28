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
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('ensureTag','ipdf',...
  'ensureAppdata',{{'CS',f.CS}},...
  'name',['Inverse Pole figures of ' f.CS.mineral],...
  'datacursormode',@tooltip,varargin{:});

% take inverse pole figure directions from figure
r = getappdata(mtexFig.parent,'inversePoleFigureDirection');

if isNew || isempty(r) || ~isa(mtexFig,'mtexFigure')
  
  r = varargin{1};
  argin_check(r,'vector3d');
  setappdata(mtexFig.parent,'inversePoleFigureDirection',r);
        
end

for ir = 1:length(r)

  % TODO: it might happen that the spherical region needs two axes
  if ir>1, mtexFig.nextAxis; end  
  
  % the crystal directions
  h = f.orientation \ r(ir);
 
  %  plot  
  h.line('fundamentalRegion','parent',mtexFig.gca,'doNotDraw',varargin{:});
  
  if isNew, mtexTitle(mtexFig.gca,char(r(ir),'LaTeX')); end

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

m = Miller(vector3d('polar',theta,rho),getappdata(gcf,'CS'));
m = round(m);
txt = char(m,'tolerance',3*degree,'commasep');
