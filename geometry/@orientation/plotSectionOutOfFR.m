function plotSectionOutOfFR(ori,varargin)
% plot orientations to inverse pole figure sections by ignoring the
% fundamental region.
% This means, the orientations are plotted as a path starting in the
% fundamental region and may go over the bounds. Hence we plot the
% symmetric equivalent orientation that is next to the previous one.
%
% Input
%  ori - @orientation
%
% Options
%  points   - number of orientations to be plotted
%  all      - plot all orientations
%
% See also
% orientation/plotSection vector3d/scatter saveFigure 

% Only for ipfSections

opt = delete_option(varargin,...
  {'lineStyle','lineColor','lineWidth','color','edgeColor','MarkerSize','Marker','MarkerFaceColor','MarkerEdgeColor','MarkerColor'},1);

ipfSec = newODFSectionPlot(ori.CS,ori.SS,varargin{:});

% Plot ipfSection
plotSection(orientation.nan,opt{:});

% Find the path of vectors
v = ori .\ ipfSec.r1;
v.CS=v.CS.properGroup;
[v(1),sym] = project2FundamentalRegion(v(1));
for i=2:length(v)
  [v(i),sym(i)] = project2FundamentalRegion(v(i),v(i-1));
end

% plot the points
hold on
scatter(v,varargin{:},'ignoreFRBoundaries')
hold off

% Add space at the boundaries
ax = gca();
sP = getappdata(ax,'sphericalPlot');
[x,y] = project(sP.proj,v,varargin{:},'ignoreFRBoundaries');
delta = 0.02;
xlim = [min(sP.bounds(1),min(x)-delta)  ,  max(sP.bounds(3),max(x)+delta)];
ylim = [min(sP.bounds(2),min(y)-delta)  ,  max(sP.bounds(4),max(y)+delta)];
set(sP.ax,'DataAspectRatio',[1 1 1],'XLim',xlim,'YLim',ylim);
