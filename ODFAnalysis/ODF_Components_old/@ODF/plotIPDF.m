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
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

argin_check(r,'vector3d');

% maybe we should call this function with add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((ishold(mtexFig.gca) && length(r)>1) || check_option(varargin,'add2all'))
  plot(odf,varargin{:},'add2all');
  return
end

% get fundamental sector for the inverse pole figure
sR = fundamentalSector(odf.CS,varargin{:});

% plotting grid
h = plotS2Grid(sR,varargin{:});
if isa(odf.CS,'crystalSymmetry'), h = Miller(h,odf.CS); end

for i = 1:length(r)

  if i>1, mtexFig.nextAxis; end

  % compute inverse pole figures
  p = ensureNonNeg(odf.calcPDF(h,r(i),varargin{:}));

  % plot
  [~,cax] = h.plot(p,'doNotDraw','smooth',varargin{:});
  mtexTitle(cax(1),char(r(i),'LaTeX'));

  % store geometry
  set(cax,'tag','ipdf');
  setappdata(cax,'inversePoleFigureDirection',r(i));
  setappdata(cax,'CS',odf.CS);
  setappdata(cax,'SS',odf.SS);

end

if isNew % finalize plot

  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  set(gcf,'Name',['Inverse Pole Figures of ',inputname(1)]);

end

% --------------- tooltip function ------------------------------
function txt = tooltip(obj,event)

[h_local,~,value] = getDataCursorPos(mtexFig);

ax = get(event,'Target');
while ~ismember(ax,mtexFig.children), ax = get(ax,'parent'); end


h_local = Miller(h_local,getappdata(ax,'CS'),'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
