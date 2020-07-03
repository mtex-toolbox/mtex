function plotSection(rot,varargin)
% plot rotations in 2d sections through the rotation space
%
% Input
%  rot - @rotation
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

oS = newODFSectionPlot(crystalSymmetry,specimenSymmetry,varargin{:});

oS.plot(rot,varargin{:});
