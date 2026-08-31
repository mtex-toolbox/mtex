classdef mtexLayout < handle
% the layout engine behind @mtexFigure
%
% Description
% Splits what @mtexFigure used to do in a single interleaved pass into three
% steps, so that the arithmetic can be computed - and tested - without a
% figure:
%
%  <mtexLayout.measure.html measure>          read the geometry off the graphics objects
%  <mtexLayout.solveLayout.html solveLayout>  pure arithmetic, no handles in and none out
%  <mtexLayout.apply.html apply>              write back only what actually moved
%
% <mtexLayout.resolve.html resolve> drives the three until the decoration
% band stops moving. solveLayout is static: give it a spec struct and it
% returns every position with no figure existing anywhere, which is what
% tests/core/check_mtexLayout exercises.
%
% See also
% mtexFigure mtexFigure/drawNow

properties (Access = private)
  busy = false            % a layout pass is running
  held = 0                % suspend depth, see hold
  heldFig                 % the @mtexFigure to lay out when the last hold ends
  lastToken               % what the cached measurement was taken under
  lastSpec                % the cached measurement
  lastPlan                % the last plan solved, returned to re-entrant callers
  ratioAxes = gobjects(0,1) % axes the cached ratios belong to
  ratioKey = []           % camera state each was measured under
  ratioValue = []         % height/width
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

  function release = hold(lay,mtexFig)
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
    %   release = mtexFig.layout.hold(mtexFig);  % released when cleared
    %
    % See also
    % layoutHold mtexLayout/resolve

    lay.held = lay.held + 1;
    lay.heldFig = mtexFig;
    release = onCleanup(@() lay.unhold);

  end

  function unhold(lay)
    % end one hold, and lay the figure out if it was the last

    lay.held = max(0,lay.held - 1);
    if lay.held == 0, lay.heldFig = []; end

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

  function ratio = ratioOf(lay,ax)
    % height/width to shape an axes with, remembered per camera
    %
    % axesRatio projects the eight corners of the plot box onto the camera.
    % calcPartition used to ask for it once per candidate grid and drawNow
    % about 3n times in all, always with the camera untouched in between.

    % a polar axes is circular and has no camera to derive a ratio from
    if isa(ax,'matlab.graphics.axis.PolarAxes'), ratio = 1; return; end

    key = [ax.CameraPosition ax.CameraTarget ax.CameraUpVector ...
      ax.PlotBoxAspectRatio ax.DataAspectRatio];

    hit = lay.ratioAxes == ax;
    if any(hit) && isequal(lay.ratioKey(hit,:),key)
      ratio = lay.ratioValue(hit);
      return
    end

    ratio = axesRatio(ax);

    if any(hit)
      lay.ratioKey(hit,:) = key;
      lay.ratioValue(hit) = ratio;
    else
      lay.ratioAxes = [lay.ratioAxes; ax];
      lay.ratioKey = [lay.ratioKey; key];
      lay.ratioValue = [lay.ratioValue; ratio];
    end

    % drop entries whose axes have gone
    alive = isgraphics(lay.ratioAxes);
    if ~all(alive)
      lay.ratioAxes = lay.ratioAxes(alive);
      lay.ratioKey = lay.ratioKey(alive,:);
      lay.ratioValue = lay.ratioValue(alive);
    end

  end

end

end
