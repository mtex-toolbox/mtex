function h = plotAxisDistribution(obj,varargin)
% plot axis distribution
%
% Input
%  odf - @ODF
%  ori - @orientation
%  cs1, cs2 - crystal symmetry
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

if isa(obj,'symmetry')
  cs1 = obj;
  if nargin > 1 && isa(varargin{1},'symmetry')
    cs2 = varargin{1};
  else
    cs2 = specimenSymmetry;
  end
else
  cs1 = obj.CS;
  cs2 = obj.SS;
end
cs1 = cs1.properGroup;
cs2 = cs2.properGroup;

dcs = disjoint(cs1,cs2);
if check_option(varargin,'antipodal') || ...
    ((isa(obj,'orientation') || isa(obj,'ODF')) && obj.antipodal)
  dcs = dcs.Laue; 
end

if isa(obj,'quaternion') && ~isa(obj,'symmetry')

  axes = Miller(obj.axis,dcs);

  h = plot(axes,'symmetrised','FundamentalRegion',varargin{:});    
  
else

  % plotting grid
  sR = fundamentalSector(dcs,varargin{:});
  if isa(obj,'symmetry')
    h = plotS2Grid(sR,'resolution',.5*degree,varargin{:});
  else
    h = plotS2Grid(sR,'resolution',2.5*degree,varargin{:});
  end

  % plot  
  varargin = delete_option(varargin,'complete');
  density = pos(calcAxisDistribution(obj,h,varargin{:}));
  h = smooth(h,density,varargin{:});

end
  
if isNew % finalize plot
  name = inputname(1);
  set(gcf,'Name',['Axis Distribution of ',name]);
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

if nargout == 0, clear h; end


function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end

