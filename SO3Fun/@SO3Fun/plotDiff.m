function plotDiff(SO3F1,SO3F2,varargin)
% difference plot between two SO3Funs or an SO3Fun and a pole figure
%
% Syntax
%   plotDiff(SO3F1,SO3F2,...,param,val,...)
%   plotDiff(SO3F1,pf,...,param,val,...)
%
% Input
%  SO3F1,SO3F2  - @SO3Fun
%  pf   - @PoleFigure
%
% Options
%  RP - calculate RP error (only for SO3Fun -- pole figure)
%  l1 - calculate $|pf1--pf2|$ error (only for SO3Fun -- pole figure)
%  l2 - calculate $|pf1--pf2|^2$ error (only for SO3Fun -- pole figure)
%
% See also
% S2Grid/plot PoleFigure/calcError SO3Fun/calcError savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

if isa(SO3F2,'PoleFigure')
  plot(calcErrorPF(SO3F2,SO3F1,varargin{:}),'colorrange','equal',varargin{:})
else
  plotSection(SO3F1-SO3F2,varargin{:})
end
