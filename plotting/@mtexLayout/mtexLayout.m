classdef mtexLayout < handle
% the layout engine behind @mtexFigure
%
% Description
% Three steps, so that the arithmetic can be computed - and tested - without
% a figure:
%
%  <mtexLayout.measure.html measure>          read the geometry off the graphics objects
%  <mtexLayout.solveLayout.html solveLayout>  pure arithmetic, no handles in and none out
%  <mtexLayout.apply.html apply>              write back only what actually moved
%
% <mtexLayout.resolve.html resolve> drives the three until nothing moves.
% solveLayout is static: give it a spec struct and it returns every position
% with no figure existing anywhere, which is what tests/core/check_mtexLayout
% exercises.
%
% See also
% mtexFigure mtexFigure/drawNow

properties (Access = private)
  busy = false            % a layout pass is running
  held = 0                % suspend depth, see hold
  lastToken               % what the cached measurement was taken under
  lastSpec                % the cached measurement
  lastPlan                % the last plan solved, returned to re-entrant callers
end

methods (Static)
  plan = solveLayout(spec)
end

methods

  function clearBusy(lay)
    % only for the onCleanup in resolve - a local function in a method file
    % is not a method and would not reach a private property

    lay.busy = false;

  end

  function release = hold(lay)
    % stop laying out until the returned onCleanup goes out of scope
    %
    % Building a figure calls drawNow once per plot command, and every one of
    % them is superseded by the next: plotPDF of three pole figures laid the
    % figure out four times and measured it seventeen. Hold it while building
    % and the layout happens once, when there is something final to lay out.
    %
    % Releasing does NOT lay out - the drawNow that every such command already
    % ends with does, and resolving here as well would cost a second full
    % layout. So take the hold after any early return, not before it.
    %
    % Syntax
    %   release = mtexFig.layout.hold;  % released when cleared
    %
    % See also
    % layoutHold mtexLayout/resolve

    lay.held = lay.held + 1;
    release = onCleanup(@() lay.unhold);

  end

  function unhold(lay)
    lay.held = max(0,lay.held - 1);
  end

  function tf = isHeld(lay)
    tf = lay.held > 0;
  end

  function tf = isSettled(lay,mtexFig)
    % the figure still has the size it was last measured at
    %
    % Printing nudges a figure by a pixel or two and the resize callback comes
    % straight back here, in the middle of the capture. The comparison is
    % against what was measured, not against what the plan asked for: the two
    % differ whenever the ask was refused, and resizing a figure to the size
    % the layout wanted has to lay it out, not be taken for a nudge.

    pos = get(mtexFig.parent,'Position');
    tf = ~isempty(lay.lastSpec) && all(abs(pos(3:4) - lay.lastSpec.figSize) <= 4);

  end

  function invalidate(lay)
    % forget the cached measurement, so the next resolve reads the figure again

    lay.lastToken = [];
    lay.lastSpec = [];

  end

  function resize(lay,mtexFig,position)
    % give the figure a size, without the resize callback coming straight back
    %
    % A [w h] is centred on the screen and capped at it: a figure larger than
    % the screen is one the window manager shrinks and the snapshot then
    % squeezes. An [x y w h] is taken as given.

    fig = mtexFig.parent;
    if fig.WindowStyle == "docked", return; end

    if numel(position) == 2
      screen = mtexFig.screenExtent;
      position = min(position,screen);
      position = [(screen - position)/2, position];
    end

    % onCleanup rather than a plain restore: an error in between used to leave
    % the figure with no ResizeFcn at all, i.e. permanently deaf to being resized
    old = fig.ResizeFcn;
    fig.ResizeFcn = [];
    restore = onCleanup(@() set(fig,'ResizeFcn',old)); %#ok<NASGU>

    fig.Position = position;

    % the space to lay out in just changed
    lay.invalidate;

  end

end

end
