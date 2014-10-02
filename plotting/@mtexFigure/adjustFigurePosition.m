function hasChanged = adjustFigurePosition(mtexFig)
% determine optimal size
      
screenExtend = get(0,'MonitorPositions');
screenExtend = screenExtend(1,:); % consider only the first monitor
screenExtend = screenExtend(3:4);
      
% compute best partioning
calcBestFit(mtexFig,'screen','maxWidth',300);
      
% resize figure
width = mtexFig.axesWidth;
height = mtexFig.axesHeight;
position = [(screenExtend(1)-width)/2,(screenExtend(2)-height)/2,width,height];


pos = get(mtexFig.parent,'position');
hasChanged = any(pos ~= position);

set(mtexFig.parent,'position',position);

end
