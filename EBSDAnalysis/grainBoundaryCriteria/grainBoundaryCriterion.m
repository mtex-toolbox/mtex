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

methods

  function obj = prepare(obj,ebsd) %#ok<INUSD>
    % Optional preprocessing hook.
    %
    % Subclasses may overload this method if they want to cache data
    % derived from the EBSD object before evaluate is called repeatedly.
  end

  function out = eval(obj,ebsd,i,j)
    % Evaluate criterion on neighboring pixel pairs.
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