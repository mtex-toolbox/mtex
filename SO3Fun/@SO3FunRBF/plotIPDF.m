function plotIPDF(SO3F,r,varargin)
% plot inverse pole figures
%
% Input
%  odf - @SO3FunHarmonic
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

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end

plotIPDF@SO3Fun(SO3F.subSet(1),r,varargin{:});

end