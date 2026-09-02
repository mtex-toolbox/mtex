function changed = adoptColorbars(mtexFig)
% take over colorbars that were added behind mtexFigure's back
%
% Output
%  changed - whether the set of adopted colorbars changed
%
% Description
% A plain colorbar(...) call - rather than mtexColorbar or mtexFig.colorbar -
% leaves mtexFig.cBarAxis empty. The layout would then hand the axes the whole
% figure and MATLAB would shrink it again to fit the bar, and where the bar
% ended up would depend on how many resize events had happened. Adopting it
% settles that: the layout reserves a band for it and positions it there.
%
% Also drops handles of colorbars that have meanwhile been deleted.
%
% See also
% adoptLegend mtexLayout/measure

cBar = findobj(mtexFig.parent,'Type','colorbar');

% order them like mtexFig.children, the layout pairs cBarAxis(i) with children(i)
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

% a stale handle - the colorbar was deleted meanwhile - counts as a change too
old = mtexFig.cBarAxis(:);
changed = ~isequal(old,found) || ~all(isgraphics(old));

if ~changed, return; end

if ~isempty(found)

  % take the side from the colorbar itself, before the layout's Position
  % assignments switch its Location to 'manual'
  mtexFig.cBarSide = cBarSideOf(found(1),mtexFig.cBarSide);

  set(found,'Units','pixels');

  % give them the thickness mtexFig.colorbar uses, before anything is measured
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
