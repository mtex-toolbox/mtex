function figResize(fig,evt,mtexFig) %#ok<INUSL,INUSL>
% resize figure and reorder subfigs

% check autofit is enabled
if isempty(mtexFig.children), return;end

% store old units and perform all calculations in pixel
old_units = get(fig,'Units');
set(fig,'Units','pixels');

figSize = get(mtexFig.parent,'Position');
figSize = figSize(3:4) - 2*mtexFig.outerPlotSpacing;

mtexFig.calcBestFit;

% align axes according to the partioning
for i = 1:length(mtexFig.children)
  [col,row] = ind2sub([mtexFig.ncols mtexFig.nrows],i);
  axisPos = [1+mtexFig.outerPlotSpacing+(col-1)*(mtexFig.axisWidth+mtexFig.innerPlotSpacing),...
    1+mtexFig.outerPlotSpacing+figSize(2)-row*mtexFig.axisHeight-(row-1)*(mtexFig.innerPlotSpacing-1),...
    mtexFig.axisWidth,mtexFig.axisHeight];
  set(mtexFig.children(i),'Units','pixels','Position',axisPos);
  
end

% resize colorbaraxis
%set(mtexFig.cBarAxis,'units','pixel','position',[mtexFig.outerPlotSpacing,mtexFig.outerPlotSpacing,figSize]);

% revert figure units
set(fig,'Units',old_units);

end
