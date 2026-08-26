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
  lastToken               % what the cached measurement was taken under
  lastSpec                % the cached measurement
  lastPlan                % the last plan solved, returned to re-entrant callers
  ratioAxes = gobjects(0,1) % axes the cached ratios belong to
  ratioKey = []           % camera state each was measured under
  ratioValue = []         % height/width
  insetAxes = gobjects(0,1) % axes the cached decoration bands belong to
  insetKey = {}           % what each was measured under, see insetOf
  insetValue = zeros(0,4) % the band
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
