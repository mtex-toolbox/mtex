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


% generate empty ipf plots
[ipfP,mtexFig,isNew] = ipfPlot.new(odf.CS,r,varargin{:},'datacursormode',@tooltip);

% plotting grid
h = plotS2Grid(ipfP(1).sphericalRegion,varargin{:});
if isa(odf.CS,'crystalSymmetry'), h = Miller(h,odf.CS); end

% plot
for i = 1:length(ipfP)

  % compute inverse pole figures
  p = ensureNonNeg(odf.calcPDF(h,ipfP(i).r,varargin{:}));

  % plot
  h.smooth(p,'parent',mtexFig.gca,'doNotDraw',varargin{:});

end


if isNew % finalize plot

  pause(1)
  set(gcf,'Name',['Inverse Pole Figures of ',inputname(1)]);
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
end

% --------------- tooltip function ------------------------------
function txt = tooltip(varargin)

[h_local,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,getappdata(mtexFig.parent,'CS'),'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end

