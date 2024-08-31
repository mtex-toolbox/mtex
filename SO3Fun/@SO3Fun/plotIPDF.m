function plotIPDF(SO3F,r,varargin)
% plot inverse pole figures
%
% Input
%  odf - @SO3Fun
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

% maybe we should call this function with add2all
if ~isNew && ~check_option(varargin,'parent') && ...
    ((ishold(mtexFig.gca) && length(r)>1) || check_option(varargin,'add2all'))
  plot(SO3F,varargin{:},'add2all');
  return
end

for i = 1:length(r)

  if i>1, mtexFig.nextAxis; end

  %  inverse pole density function
  ipdf = radon(SO3F,[],r(i),varargin{:});
  
  % plot it
  [~,cax] = plot(ipdf,'doNotDraw','smooth','ensureNonNeg',varargin{:});
  mtexTitle(cax(1),char(r(i),'LaTeX'));

  % store geometry
  [cax.Tag] = deal('ipdf');
  setappdata(cax,'inversePoleFigureDirection',r(i));
  setappdata(cax,'CS',SO3F.CS);
  setappdata(cax,'SS',SO3F.SS);

end

if isNew % finalize plot

  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  set(gcf,'Name',['Inverse Pole Figures of ',inputname(1)]);

end

% --------------- tooltip function ------------------------------
function txt = tooltip(~,event)

[h_local,~,value] = getDataCursorPos(mtexFig);

ax = event.Target;
while ~ismember(ax,mtexFig.children), ax = ax.Parent; end


h_local = Miller(h_local,getappdata(ax,'CS'),'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
