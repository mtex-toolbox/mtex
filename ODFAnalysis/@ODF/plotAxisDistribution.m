function h = plotAxisDistribution(odf,varargin)
% plot axis distribution
%
% Input
%  odf - @ODF
%
% Options
%  RESOLUTION - resolution of the plots
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure(varargin{:});

% plotting grid
sR = fundamentalSector(disjoint(odf.CS,odf.SS),'antipodal',varargin{:});
h = plotS2Grid(sR,'antipodal','resolution',2.5*degree,varargin{:});

% plot
density = pos(calcAxisDistribution(odf,h,varargin{:}));
h = smooth(h,density,'parent',mtexFig.gca,varargin{:},'doNotDraw');

if isNew % finalize plot
  setappdata(gcf,'CS',odf.CS);
  name = inputname(1);
  set(gcf,'Name',['Axis Distribution of ',name]);
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

if nargout == 0, clear h; end


function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
