classdef (Abstract) grainBoundaryCriterion
% grainBoundaryCriterion Abstract base class for EBSD grain boundary criteria
%
% A grainBoundaryCriterion decides, for pairs of neighboring EBSD pixels,
% whether the edge between them is a grain boundary.
%
% The public API is
%
%   out = criterion.evaluate(ebsd,i,j)
%
% where i and j are equally sized arrays of neighboring pixel indices.
%
% The output out must have the same size as i and j. The convention is:
%
%   out = 1    no grain boundary
%   out = 0.5  low-angle grain boundary
%   out = 0    high-angle grain boundary
%
% Subclasses implement the protected method doEvaluate.
%
% Syntax
%   grains = calcGrains(ebsd,gbcAngle(10*degree))
%   out = criterion.evaluate(ebsd,i,j)
%
% Input
%  ebsd - @EBSD
%  i, j - equally sized arrays of neighbouring pixel indices
%
% Output
%  out - one value per pair, between 0 and 1
%
% Derived Classes
%  @gbcAngle    - threshold on the misorientation angle
%  @gbcSoft     - a smooth transition instead of a threshold
%  @gbcFMC      - fast multiscale clustering
%  @gbcVariants - boundaries between variants of a parent grain
%  @gbcCustom   - criterion given by a function handle
%
% See also
% EBSD/calcGrains gbcAngle gbcFMC
%

methods

  function obj = prepare(obj,ebsd) %#ok<INUSD>
    % Optional preprocessing hook.
    %
    % Subclasses may overload this method if they want to cache data
    % derived from the EBSD object before evaluate is called repeatedly.
  end

  function out = eval(obj,ebsd,i,j)
    % Evaluate criterion on neighboring pixel pairs.
    %
    % Gridded data pads the lattice sites that hold no measurement with
    % phaseId = NaN (see EBSD/private/squarify), and every criterion picks
    % its pixels with a test of the form phaseId(i) == p. NaN compares
    % false against every phase, so pad cells matched no phase at all,
    % scored 0, and came out separated from each of their neighbours by a
    % boundary: a solid 5841 cell hole segmented into 5842 single-pixel
    % notIndexed grains instead of one. Marking the hole notIndexed by
    % hand, i.e. phaseId = 1 with the positions present, gave 6 grains on
    % the same map - so the two representations of "nothing was measured
    % here" disagreed, although spatialDecompositionGrid's help already
    % states they are treated identically.
    %
    % Normalising here rather than in calcGrains covers every caller
    % (doSegmentation, gridComponents for the minPixel pass, the quadruple
    % point merge, calcGrainsOld) and every subclass at once, and because
    % ebsd is passed by value it cannot leak back out - in particular the
    % NaN padding survives on whatever calcGrains returns, so EBSD(ebsd)
    % still strips it.
    %
    % Phase 1 as "notIndexed" is the same assumption calcGrains already
    % makes when the minPixel pass writes ebsd.phaseId(removed) = 1.
    isPad = isnan(ebsd.phaseId);
    if any(isPad), ebsd.phaseId(isPad) = 1; end

    out = obj.doEvaluate(ebsd,i,j);
  end

  function tf = handlesMinPixel(obj) %#ok<MANU>
    % Does this criterion enforce minPixel itself?
    %
    % calcGrains normally enforces minPixel with a whole extra
    % segmentation pass, which finds the undersized grains and marks their
    % pixels notIndexed. A criterion that already deals with undersized
    % regions internally answers true, and that pass - a second complete
    % evaluation of the criterion - is skipped.
    tf = false;
  end

  function obj = setMinPixel(obj,minPixel) %#ok<INUSD>
    % Hand minPixel to a criterion that answers true above.
    %
    % Does nothing by default, so a criterion only has to override this
    % together with handlesMinPixel.
  end

end

methods (Access = protected, Abstract)
  out = doEvaluate(obj,ebsd,i,j)
end

end