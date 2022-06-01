function plotPDF(SO3F,h,varargin)
% plot pole density function
%
% Syntax
%   plotPDF(odf,[h1,..,hN])
%   plotPDF(odf,{[h11,h12],h2,hN],'superposition',{[c11,c12],c2,cN})
%   plotPDF(odf,pf.h,'superposition',pf.c)
%
% Input
%  odf - @SO3FunHarmonic
%  h   - @Miller crystallographic directions
%  c   - structure coefficients
%
% Options
%  resolution    - resolution of the plots
%  superposition - plot superposed pole figures
%
% Flags
%  noTitle   - suppress the Miller indices at the top
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot annotate savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end

plotPDF@SO3Fun(SO3F.subSet(1),h,varargin{:});

end