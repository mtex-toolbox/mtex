function h = plotAxisDistribution(obj,varargin)
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
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure(varargin{:});

if isa(obj,'grainBoundary')

else
  
  if isa(obj,'ODF')
    cs1 = obj.CS;
    cs2 = obj.SS;
  elseif isa(obj,'symmetry')
    cs1 = obj;
    if nargin > 1 && isa(varargin{1},'symmetry')
      cs2 = varargin{1};
    else
      cs2 = specimenSymmetry;
    end
  end

  % plotting grid
  sR = fundamentalSector(disjoint(cs1,cs2),varargin{:});
  h = plotS2Grid(sR,'antipodal','resolution',2.5*degree,varargin{:});

  % plot
  %h = project2FundamentalRegion(h,disjoint(cs1,cs2))
  density = pos(calcAxisDistribution(obj,h,varargin{:}));
  h = smooth(h,density,'parent',mtexFig.gca,varargin{:},'doNotDraw');

end
  
if isNew % finalize plot
  name = inputname(1);
  set(gcf,'Name',['Axis Distribution of ',name]);
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

if nargout == 0, clear h; end


function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
