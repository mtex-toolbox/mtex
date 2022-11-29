function plotSection(SO3F,varargin)
% plot ODF sections
%
% Options
%  sections - number of sections
%  points   - number of orientations to be plotted
%  all      - plot all orientations
%  resolution - resolution of each plot
%
% Flags
%  phi2      - phi2 sections (default)
%  phi1      - phi1 sections
%  gamma     - gamma sections
%  sigma     - sigma = phi1 - phi2 sections
%  axisAngle - rotational angle sections
%  smooth
%  countourf
%  contour
%  contour3, surf3, slice3 - 3d volume plot
%
% See also
% saveFigure Plotting

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end

plotSection@SO3Fun(SO3F.subSet(1),varargin{:});

end