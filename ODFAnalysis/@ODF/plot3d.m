function plot3d(odf,varargin)
% plots odf
%
% generate grids
[S3G,S2G,sec] = plotSO3Grid(odf.CS,odf.SS,'resolution',2.5*degree,varargin{:});

Z = eval(odf,orientation(S3G),varargin{:});
clear S3G;

sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','omega','axisangle'},'phi2');
[symbol,labelx,labely] = sectionLabels(sectype);

[xlim, ylim] = polar(S2G);

v = get_option(varargin,{'surf3','contour3'},10,'double');
contour3s(xlim(:,1).'./degree,ylim(1,:)./degree,sec./degree,Z,v,'surf3',varargin{:},...
  'xlabel',labely,'ylabel',labelx,'zlabel',['$' symbol '$']);

  
set(gcf,'Name',['ODF ' sectype '-sections "',inputname(1),'"']);
setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);
setappdata(gcf,'CS',odf.CS);
setappdata(gcf,'SS',odf.SS);
set(gcf,'tag','odf3d')
  
end
