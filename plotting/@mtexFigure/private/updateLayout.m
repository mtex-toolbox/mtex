function updateLayout(mtexFig)
% resize figure and reorder subfigs

if isempty(mtexFig.children), return;end

% store old units and perform all calculations in pixel
old_units = get(mtexFig.parent,'Units');
set(mtexFig.parent,'Units','pixels');

figSize = get(mtexFig.parent,'Position');
figSize = figSize(3:4) - sum(reshape(mtexFig.figTightInset,2,2),2).';

% compute layout
[mtexFig.ncols,mtexFig.nrows] = calcPartition(mtexFig,figSize);
[mtexFig.axisWidth,mtexFig.axisHeight] = calcAxesSize(mtexFig,figSize);

% align axes according to layout
for i = 1:length(mtexFig.children)
  
  % compute position in raster
  [col,row] = ind2sub([mtexFig.ncols mtexFig.nrows],i);
  
  aw = mtexFig.axisWidth + mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([1,3]));
  ah = mtexFig.axisHeight + mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([2,4]));
  
  axisPos = [mtexFig.figTightInset(1:2),0,0] + ...
  [1 + (col-1)*aw + mtexFig.tightInset(1),...
    1 + figSize(2) - row * ah ...
    + mtexFig.innerPlotSpacing + mtexFig.tightInset(2),...
    mtexFig.axisWidth,mtexFig.axisHeight];
  axisPos(axisPos<0)=0;
  set(mtexFig.children(i),'Units','Pixel','Position',axisPos);
  
  % position the colorbars
  if numel(mtexFig.cBarAxis) == numel(mtexFig.children)

    resizeColorBar(mtexFig.cBarAxis(i))
    
  end
end

if length(mtexFig.cBarAxis)==1 && i>1
  pos = get(mtexFig.cBarAxis,'position');
  
  if pos(4)>pos(3) %Vertical bar
    
    pos(4) = mtexFig.nrows * mtexFig.axisHeight + ...
      (mtexFig.nrows-1) * (mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([2,4])));
    pos(2) = axisPos(2)+1;
    pos(1) = mtexFig.ncols*(mtexFig.axisWidth + mtexFig.innerPlotSpacing + ...
      sum(mtexFig.tightInset([1,3]))) + mtexFig.outerPlotSpacing;

  else  %Horizontal bar
    
    pos(3)=mtexFig.ncols*(mtexFig.axisWidth) + ...
      (mtexFig.ncols-1) * (mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([1,3]))); %c_bar width
    pos(2) = mtexFig.outerPlotSpacing + 2*pos(4);%axisPos(2) - 2*pos(4);
    pos(1) = mtexFig.outerPlotSpacing + mtexFig.tightInset(1); %c_bar left
    
  end
  set(mtexFig.cBarAxis,'position',pos);
end
  
% revert figure units
set(mtexFig.parent,'Units',old_units);


  function resizeColorBar(cBar)
  
    pos = get(cBar,'position');
    if pos(4) > pos(3) % vertical
      set(cBar,'position',...
        [axisPos(1)+mtexFig.axisWidth+10,...
        axisPos(2)+1,...
        pos(3),mtexFig.axisHeight-1]);
    else % horizonal
      set(cBar,'position',...
        [axisPos(1),...
        axisPos(2)-mtexFig.tightInset(2) + mtexFig.cBarShift,...
        mtexFig.axisWidth-1,pos(4)]);
    end
  end
  
function testit

close all
mtexFig = mtexFigure;
mtexFig.gca
rectangle('position',[0,0,1,1])
axis equal  tight
title('asdsa')
xlabel('asd')
mtexFig.nextAxis;
rectangle('position',[0,0,1,1])
axis equal tight
xlabel('asd')

title('asdasd2')
axis(mtexFig.children(1),'off')
axis(mtexFig.children(2),'off')

mtexFig.drawNow

end


end

