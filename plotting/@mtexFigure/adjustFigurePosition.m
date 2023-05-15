function hasChanged = adjustFigurePosition(mtexFig)
% determine optimal size
      
screenExtent = get(0,'MonitorPositions');
screenExtent = screenExtent(1,:); % consider only the first monitor
screenExtent = screenExtent(3:4);
      
% compute best partioning
calcBestFit(mtexFig,'screen','maxWidth',300);
      
% resize figure
width = mtexFig.axesWidth;
height = mtexFig.axesHeight;
position = [(screenExtent(1)-width)/2,(screenExtent(2)-height)/2,width,height];


pos = get(mtexFig.parent,'position');
hasChanged = any(pos ~= position);

set(mtexFig.parent,'position',position);

end
