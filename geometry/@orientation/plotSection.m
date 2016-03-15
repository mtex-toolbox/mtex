function plotSection(ori,varargin)
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

if ori.antipodal, varargin = ['antipodal',varargin]; end
oS = newODFSectionPlot(ori.CS,ori.SS,varargin{:});

oS.plot(ori,varargin{:});
