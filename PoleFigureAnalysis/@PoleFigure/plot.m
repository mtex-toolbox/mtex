function plot(pf,varargin)
% plot pole figure
%
% plots the diffraction intensities
%
% Input
%  pf - @PoleFigure
%
% Options
%  background   - plot background data
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

[mtexFig,isNew] = newMtexFigure(varargin{:}); 
  
for i = 1:length(pf.allH)
  
  if i>1, mtexFig.nextAxis; end
  
  pf.allR{i}.plot(pf.allI{i},'TR','',...
    'dynamicMarkerSize','parent',mtexFig.gca,'doNotDraw',varargin{:});
  %title(mtexFig.gca,char(pf.allH{i},'LaTex'),...
  %  'FontSize',getMTEXpref('FontSize'),'Interpreter','LaTex');
  title(mtexFig.gca,char(pf.allH{i}),'FontSize',getMTEXpref('FontSize'));
end

if isNew % finalize plot
  setappdata(gcf,'h',pf.allH);
  setappdata(gcf,'SS',pf.SS);
  setappdata(gcf,'CS',pf.CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');
  mtexFig.drawNow('autoPosition',varargin{:});
end
