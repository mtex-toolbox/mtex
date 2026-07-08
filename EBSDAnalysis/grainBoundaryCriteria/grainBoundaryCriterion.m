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

end

methods (Access = protected, Abstract)
  out = doEvaluate(obj,ebsd,i,j)
end

end