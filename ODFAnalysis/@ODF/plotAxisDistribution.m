function plotAxisDistribution(odf,varargin)
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

% make new plot
[ax,odf,varargin] = getAxHandle(odf,varargin{:});
if isempty(ax), newMTEXplot;end

% plotting grid
[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(disjoint(odf.CS,odf.SS),'antipodal',varargin{:});
h = plotS2Grid('minTheta',minTheta,'maxTheta',maxTheta,...
  'maxRho',maxRho,'minRho',minRho,'RESTRICT2MINMAX','antipodal',varargin{:});

% plot
smooth(ax{:},h,pos(calcAxisDistribution(odf,h,varargin{:})),varargin{:});

if isempty(ax)
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','AxisDistribution');
end
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
name = inputname(1);
set(gcf,'Name',['Axis Distribution of ',name]);

function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
