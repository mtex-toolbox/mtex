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

% plotting grid
sR = fundamentalSector(disjoint(odf.CS,odf.SS),'antipodal',varargin{:});
h = plotS2Grid(sR,'antipodal',varargin{:});

% plot
smooth(h,pos(calcAxisDistribution(odf,h,varargin{:})),varargin{:});

setappdata(gcf,'CS',odf.CS);
setappdata(gcf,'SS',odf.SS);
set(gcf,'tag','AxisDistribution');

name = inputname(1);
set(gcf,'Name',['Axis Distribution of ',name]);

function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
