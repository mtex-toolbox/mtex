function plotDiff(odf1,odf2,varargin)
% difference plot between two odfs or an odf and a pole figure
%
% Syntax
%   plotDiff(odf1,odf2,...,param,val,...)
%   plotDiff(odf,pf,...,param,val,...)
%
% Input
%  odf1  - @ODF     
%  odf2  - @ODF     
%  pf   - @PoleFigure
%
% Options
%  RP - calculate RP error (only for odf -- pole figure)
%  l1 - calculate $|pf1--pf2|$ error (only for odf -- pole figure)
%  l2 - calculate $|pf1--pf2|^2$ error (only for odf -- pole figure)
%
% See also
% S2Grid/plot PoleFigure/calcError ODF/calcError savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

% where to plot
[ax,odf1,odf2,varargin] = getAxHandle(odf1,odf2,varargin{:});

if isa(odf2,'PoleFigure')
  plot(ax{:},calcErrorPF(odf2,odf1,varargin{:}),'colorrange','equal',varargin{:})
else
  plotODF(ax{:},odf1-odf2,varargin{:})
end
