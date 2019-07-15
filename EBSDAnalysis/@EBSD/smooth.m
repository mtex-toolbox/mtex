function [ebsd,filter] = smooth(ebsd,varargin)
% smooth spatial EBSD 
%
% Input
%  ebsd - @EBSD
%
% Example
%   mtexdata forsterite
%   ebsd = ebsd('indexed');
%   % segment grains
%   [grains,ebsd.grainId] = calcGrains(ebsd)
%
%   % find largest grains
%   largeGrains = grains(grains.grainSize>800)
%   ebsd = ebsd(largeGrains(1))
%
%   figure
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold on
%   oM = ipfHSVKey(ebsd);
%   oM.inversePoleFigureDirection = mean(ebsd.orientations) * oM.whiteCenter;
%   oM.colorStretching = 50;
%   plot(ebsd,oM.orientation2color(ebsd.orientations))
%   hold off
%
%   ebsd_smoothed = smooth(ebsd)
%   plot(ebsd_smoothed('indexed'),oM.orientation2color(ebsd_smoothed('indexed').orientations))
%   hold on
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold off

% make a gridded ebsd data set
ebsd = ebsd.gridify(varargin{:});

% fill holes if needed
if check_option(varargin,'fill'), ebsd = fill(ebsd,varargin{:}); end

[ebsd,filter] = smooth(ebsd,varargin{:});

% remove nan data used to generate the grid
ebsd = ebsd.subSet(~isnan(ebsd.phaseId));

