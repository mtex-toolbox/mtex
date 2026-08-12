function updateLayout(mtexFig)
% resize figure and reorder subfigs

if isempty(mtexFig.children), return;end

% Pick up colorbars that were added behind mtexFigure's back: a plain
% colorbar(...) call - rather than mtexColorbar / mtexFig.colorbar - leaves
% mtexFig.cBarAxis empty. The layout below would then hand the axes the
% whole figure again, and MATLAB, which keeps a colorbar glued to the
% outside of its peer axes, follows along - pushing a 'southoutside' bar
% clean off the bottom of the figure. Adopting it instead lets the regular
% colorbar handling reserve a band for it and keep it positioned there.
% This also drops handles of colorbars that have meanwhile been deleted.
%
% The tight inset has to be recomputed on any such change: it is what
% reserves the band, and it is also where cBarShift - used by
% resizeColorBar below - is determined.
%
% The same applies to a legend asked to sit outside the axes, see
% adoptLegend.
changed = adoptColorbars;
changed = adoptLegend(mtexFig) || changed;
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

  % bounding box of all axes, used to place a bar on the side the raster
  % does not grow from - the east and south formulas below are expressed in
  % the raster geometry and are left as they are
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

% position the legend within the band calcTightInset has reserved for it -
% at mtexFig.legendSpacing from the axes and centered along the other
% direction
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


  function changed = adoptColorbars
    % sync mtexFig.cBarAxis with the colorbars actually present - see above

    cBar = findobj(mtexFig.parent,'Type','colorbar');

    % order them like mtexFig.children, since the layout above pairs
    % cBarAxis(i) with children(i). A single colorbar shared by several axes
    % is peered to one of them and so is picked up here as well.
    found = gobjects(0,1);
    if ~isempty(cBar)
      peer = gobjects(numel(cBar),1);
      for k = 1:numel(cBar)
        try peer(k) = cBar(k).Axes; catch, end %#ok<TRYNC>
      end
      for k = 1:numel(mtexFig.children)
        found = [found; cBar(peer == mtexFig.children(k))]; %#ok<AGROW>
      end
    end

    old = reshape(mtexFig.cBarAxis(:),[],1);

    % the empty cases are spelled out separately: cBarAxis starts out as []
    % (a double), so comparing it to a graphics array with == would throw
    if isempty(old) || isempty(found)
      changed = ~(isempty(old) && isempty(found));
    else
      % a stale handle - the colorbar was deleted meanwhile - counts as a
      % change too, and has to be caught before == sees it
      changed = numel(old) ~= numel(found) || ~all(isgraphics(old)) || ...
        ~all(found == old);
    end

    if changed
      % all colorbar geometry here - the reserved band in calcTightInset as
      % well as resizeColorBar below - is computed in pixels, which is what
      % mtexFig.colorbar creates its own colorbars in. A colorbar from a
      % plain colorbar(...) call still uses normalized units, so bring it
      % over first; this only changes the unit the position is expressed in,
      % not where the bar currently sits.
      if ~isempty(found)

        % take the side from the colorbar itself, before the Position
        % assignments below switch its Location to 'manual'
        if endsWith(found(1).Location,'outside')
          mtexFig.cBarSide = extractBefore(found(1).Location,'outside');
        end

        set(found,'Units','pixels');

        % give them the same thickness mtexFig.colorbar gives the colorbars
        % it creates itself, so that a plain colorbar(...) does not end up
        % looking chunkier than mtexColorbar. Has to happen before the tight
        % inset is recomputed, since that sizes the reserved band from it.
        for k = 1:numel(found)
          pos = found(k).Position;
          if pos(3) < pos(4)  % vertical bar
            pos(3) = getMTEXpref('FontSize');
          else                % horizontal bar
            pos(4) = getMTEXpref('FontSize');
          end
          found(k).Position = pos;
        end
      end
      mtexFig.cBarAxis = found;
    end

  end

  function resizeColorBar(cBar)

    pos = get(cBar,'position');

    % the orientation decides which pair of sides is possible, cBarSide
    % which of the two - a 'northoutside' bar is horizontal and belongs
    % above the axes, not below it
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

