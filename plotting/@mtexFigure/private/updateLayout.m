function updateLayout(mtexFig)
% resize figure and reorder subfigs

if isempty(mtexFig.children), return;end

% adopt colorbars and legends added by a plain colorbar(...) call, otherwise the
% layout hands the axes the whole figure and pushes them off it - the tight
% inset has to be recomputed on any such change, it reserves the band
changed = adoptColorbars(mtexFig);
changed = adoptLegend(mtexFig) || changed;

if getMTEXpref('newLayout',true)
  % a resize of a pixel or two is a print or the window manager, not a user
  if changed || ~mtexFig.layout.isSettled(mtexFig)
    % only drawNow grows the figure, so here a pinned axis height is bounded
    % by the room there is rather than by the room the screen would allow
    figSize = get(mtexFig.parent,'Position');
    mtexFig.layout.resolve(mtexFig,struct('maxSize',figSize(3:4)));
  end
  return
end

if changed
  [mtexFig.tightInset,mtexFig.figTightInset] = calcTightInset(mtexFig);
end

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

if isscalar(mtexFig.cBarAxis) && i>1
  pos = get(mtexFig.cBarAxis,'position');

  % bounding box of all axes, to place a bar on the side the raster does not grow from
  box = cell2mat(get(mtexFig.children(:),{'Position'}));

  if pos(4)>pos(3) %Vertical bar

    pos(4) = mtexFig.nrows * mtexFig.axisHeight + ...
      (mtexFig.nrows-1) * (mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([2,4]))) - ...
      (mtexFig.cBarAxis.Ruler.Exponent~=0)*2*mtexFig.cBarAxis.FontSize;
    pos(2) = axisPos(2)+1;
    if strcmp(mtexFig.cBarSide,'west')
      pos(1) = min(box(:,1)) - pos(3) - mtexFig.cBarShift;
    else
      pos(1) = mtexFig.ncols*(mtexFig.axisWidth + mtexFig.innerPlotSpacing + ...
        sum(mtexFig.tightInset([1,3]))) + mtexFig.outerPlotSpacing;
    end

  else  %Horizontal bar

    pos(3)=mtexFig.ncols*(mtexFig.axisWidth) + ...
      (mtexFig.ncols-1) * (mtexFig.innerPlotSpacing + sum(mtexFig.tightInset([1,3]))); %c_bar width
    if strcmp(mtexFig.cBarSide,'north')
      pos(2) = max(box(:,2)+box(:,4)) + mtexFig.cBarShift;
    else
      pos(2) = mtexFig.outerPlotSpacing + 2*pos(4);%axisPos(2) - 2*pos(4);
    end
    pos(1) = mtexFig.outerPlotSpacing + mtexFig.tightInset(1); %c_bar left

  end
  set(mtexFig.cBarAxis,'position',pos);
end

% position the legend within the band calcTightInset has reserved for it
if ~isempty(mtexFig.legendAxis) && all(isgraphics(mtexFig.legendAxis))

  set(mtexFig.legendAxis,'Units','pixels');
  pos = get(mtexFig.legendAxis,'Position');

  % bounding box of all axes
  box = cell2mat(get(mtexFig.children(:),{'Position'}));
  ll = min(box(:,1:2),[],1);
  box = [ll, max(box(:,1:2)+box(:,3:4),[],1) - ll];

  switch mtexFig.legendSide
    case 'east'
      pos(1) = box(1) + box(3) + mtexFig.legendSpacing;
      pos(2) = box(2) + (box(4) - pos(4))/2;
    case 'west'
      pos(1) = box(1) - mtexFig.legendSpacing - pos(3);
      pos(2) = box(2) + (box(4) - pos(4))/2;
    case 'north'
      pos(1) = box(1) + (box(3) - pos(3))/2;
      pos(2) = box(2) + box(4) + mtexFig.legendSpacing;
    case 'south'
      pos(1) = box(1) + (box(3) - pos(3))/2;
      pos(2) = box(2) - mtexFig.legendSpacing - pos(4);
  end

  % assigning a position switches the legend to manual placement, which is
  % what keeps MATLAB from resizing the axes underneath us
  set(mtexFig.legendAxis,'Position',pos);
end

% revert figure units
set(mtexFig.parent,'Units',old_units);


  function resizeColorBar(cBar)

    pos = get(cBar,'position');

    % the orientation decides which pair of sides is possible, cBarSide which of them
    if pos(4) > pos(3) % vertical
      if strcmp(mtexFig.cBarSide,'west')
        x = axisPos(1) - 10 - pos(3);
      else
        x = axisPos(1) + mtexFig.axisWidth + 10;
      end
      set(cBar,'position',[x,axisPos(2)+1,pos(3),mtexFig.axisHeight-1]);
    else % horizonal
      if strcmp(mtexFig.cBarSide,'north')
        y = axisPos(2) + mtexFig.axisHeight + mtexFig.cBarShift;
      else
        y = axisPos(2) - mtexFig.tightInset(2) + mtexFig.cBarShift;
      end
      set(cBar,'position',[axisPos(1),y,mtexFig.axisWidth-1,pos(4)]);
    end
  end

end
