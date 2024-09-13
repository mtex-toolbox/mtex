function hasChanged = adjustFigurePosition(mtexFig)
% determine optimal size
      
screenExtent = get(groot,'MonitorPositions');
screenExtent = screenExtent(1,:); % consider only the first monitor
screenExtent = screenExtent(3:4);
      
% compute best partitioning
calcBestFit(mtexFig,'screen','maxWidth',300);
      
% resize figure
width = mtexFig.axesWidth;
height = mtexFig.axesHeight;
position = [(screenExtent(1)-width)/2,(screenExtent(2)-height)/2,width,height];

hasChanged = any(mtexFig.parent.Position ~= position);

if hasChanged, mtexFig.parent.Position = position; end

end
