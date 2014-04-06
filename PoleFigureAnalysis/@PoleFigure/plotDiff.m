function plotDiff(pfmeas,pfcalc,varargin)
% difference plot between two pole figures or an odf and a pole figure
%
% Syntax
%   plotDiff(pf,pf2)
%   plotDiff(pf,odf)
%
% Input
%  pf   - @PoleFigure
%  pf2  - @PoleFigure
%  odf  - @ODF     
%
% Options
%  RP - calculate RP error
%  l1 - calculate l^1 error
%  l2 - calculate mean square error
%
% See also
% S2Grid/plot PoleFigure/calcError ODF/calcError savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

plot(calcErrorPF(pfmeas,pfcalc,varargin{:}),varargin{:})
