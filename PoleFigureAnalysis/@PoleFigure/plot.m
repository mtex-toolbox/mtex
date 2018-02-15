function plot(pf,varargin)
% plot pole figure
%
% Syntax
%   plot(pf)
%   plot(pf{1})         % plot only the first pole figure
%   plot(pf,'contour')  % contour plot
%   plot(pf,'contourf') % filled contour plot
%   plot(pf,'smooth')   % smooth plot
%   plot(pf,'minmax')   % show min and max
%   mtexColorbar        % show colorbar
%
% Input
%  pf - @PoleFigure
%

%
% See also
% vector3d/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

[mtexFig,isNew] = newMtexFigure(varargin{:}); 
pfAnnotations = getMTEXpref('pfAnnotations');

if nargin > 1 && isnumeric(varargin{1})
  data = mat2cell(varargin{1}(:),cellfun('prodofsize',pf.allI));
else
  data = pf.allI;
end

for i = 1:length(pf.allH)
  
  if isempty(pf.allI{i}), continue; end
  if i>1, mtexFig.nextAxis; end
  
  pf.allR{i}.plot(data{i},...
    'dynamicMarkerSize','parent',mtexFig.gca,'doNotDraw',varargin{:});
  mtexTitle(mtexFig.gca,char(pf.allH{i},'LaTeX'));
  pfAnnotations('parent',mtexFig.gca);
  
end

if isNew % finalize plot
  setappdata(gcf,'h',pf.allH);
  setappdata(gcf,'SS',pf.SS);
  setappdata(gcf,'CS',pf.CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  if check_option(varargin,'3d'), fcw(gcf,'-link'); end
end
