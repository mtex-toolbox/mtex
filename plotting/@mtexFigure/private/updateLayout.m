function updateLayout(mtexFig)
% the resize callback: lay the figure out again in the room it has now

if isempty(mtexFig.children), return; end

% adopt colorbars and legends added by a plain colorbar(...) call, otherwise the
% layout hands the axes the whole figure and pushes them off it
changed = adoptColorbars(mtexFig);
changed = adoptLegend(mtexFig) || changed;

% a resize of a pixel or two is a print or the window manager, not a user
if changed || ~mtexFig.layout.isSettled(mtexFig)
  % only drawNow grows the figure, so here a pinned axis height is bounded
  % by the room there is rather than by the room the screen would allow
  figSize = get(mtexFig.parent,'Position');
  mtexFig.layout.resolve(mtexFig,struct('maxSize',figSize(3:4)));
end

end
