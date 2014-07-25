function plotIPDF(odf,r,varargin)
% plot inverse pole figures
%
% Input
%  odf - @ODF
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

argin_check(r,'vector3d');

% get fundamental sector for the inverse pole figure
sR = fundamentalSector(odf.CS,varargin{:});

% plotting grid
h = plotS2Grid(sR,varargin{:});

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

for i = 1:length(r)
  if i>1, mtexFig.nextAxis; end

  % compute inverse pole figures
  p = ensureNonNeg(pdf(odf,h,r(i),varargin{:}));

  % plot
  h.smooth(p,'TR',r(i),'parent',mtexFig.gca,'doNotDraw',varargin{:});
end


if isNew % finalize plot
  
  mtexFig.drawNow('autoPosition');
  setappdata(gcf,'inversePoleFigureDirection',r);
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','ipdf');
  set(gcf,'Name',['Inverse Pole Figures of ',inputname(1)]);

  mtexFig.drawNow('autoPosition');

end

end

% --------------- tooltip function ------------------------------
function txt = tooltip(varargin)

[r,h,value] = currentVector; %#ok<ASGLU>

txt = [xnum2str(value) ' at ' char(h,'tolerance',3*degree,'commasep')];

end

function [r,h,value] = currentVector

[pos,value,ax,iax] = getDataCursorPos(gcf);

CS = getappdata(gcf,'CS');
h = Miller(vector3d('polar',pos(1),pos(2)),CS);
h = round(h);
r = getappdata(gcf,'inversePoleFigureDirection');
r = r(iax);

projection = getappdata(ax,'projection');

if projection.antipodal
  r = set_option(r,'antipodal');
end

end
