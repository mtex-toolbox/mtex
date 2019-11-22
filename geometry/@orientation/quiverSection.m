function quiverSection(ori,varargin)
% plot orientations to ODF sections
%
% Input
%  ori - @orientation
%
% Options
%  sections - number of sections
%  points   - number of orientations to be plotted
%  all      - plot all orientations
%
% Flags
%  phi2      - phi2 sections (default)
%  phi1      - phi1 sections
%  sigma     - sigma = phi1 ~ phi2 sections
%  axisAngle - rotational angle sections
%
% See also
% vector3d/scatter saveFigure 

if check_option(varargin,{'contour','contourf','smooth'})
  warning('Using the options contour, contourf or smooth in orientation sections plots is not recommented. Computing an ODF and plotting it is usually much better');
end

if ori.antipodal, varargin = [varargin,'antipodal']; end
oS = newODFSectionPlot(ori.CS,ori.SS,varargin{:});

oS.quiver(ori,varargin{:});
