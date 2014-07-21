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


% predefines axes?
if check_option(varargin,'parent')  
  paxes = get_option(varargin,'parent');
else  
  mtexFig = mtexFigure; % make new plot
  paxes = mtexFig.children;
end
  
for i = 1:length(pf.allH)
  
  if isempty(paxes), ax = mtexFig.nextAxis; else ax = paxes(i); end
  
  pf.allR{i}.plot(pf.allI{i},'TR',pf.allH{i},...
    'dynamicMarkerSize','parent',ax,'doNotDraw',varargin{:});
end

if isempty(paxes)
  setappdata(gcf,'h',pf.allH);
  setappdata(gcf,'SS',pf.SS);
  setappdata(gcf,'CS',pf.CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');
  mtexFig.drawNow('autoPosition');
end
