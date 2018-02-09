function plot(zrm,varargin)
% plot zero regions in pole figures
%
% Input
%  zrm - @zeroRangeMethod

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure(varargin{:});
pfAnnotations = getMTEXpref('pfAnnotations');

S2G = plotS2Grid(varargin{:});

for i = 1:length(zrm.density)
  
  if i>1, mtexFig.nextAxis; end

  % compute zero range
  isZero = double(zrm.checkZeroRange(S2G,i));
    
  S2G.plot(isZero,'parent',mtexFig.gca,'contourf','colorRange',[0,1],'doNotDraw',varargin{:});
  pfAnnotations('parent',mtexFig.gca,'doNotDraw');

  mtexTitle(mtexFig.gca,char(zrm.pf.allH{i},'LaTeX'));
  
end

if isNew % finalize plot
  set(gcf,'tag','pdf');
  setappdata(gcf,'SS',zrm.pf.SS);
  setappdata(gcf,'h',zrm.pf.allH);
  set(gcf,'Name',['Zero Range']);
end

drawNow(gcm)

end