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
end

if isNew % finalize plot
  setappdata(gcf,'h',pf.allH);
  setappdata(gcf,'SS',pf.SS);
  setappdata(gcf,'CS',pf.CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  if check_option(varargin,'3d')
    rotate3d(gcf);
    linkprop(mtexFig.children, 'CameraPosition');
  end
end
