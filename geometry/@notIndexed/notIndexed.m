classdef notIndexed
% the name an unindexed phase was called by before ADR 0008
%
% An unindexed phase is a <notIndexedFrame.notIndexedFrame.html
% |notIndexedFrame|>: a reference frame without a lattice. This class holds
% nothing and exists so that MATLAB finds a name for the objects in a file
% written before the change - |loadobj| converts what it reads. Constructing
% one errors and names the frame instead.
%
% See also
% notIndexedFrame referenceFrame

  methods

    function ni = notIndexed(varargin) %#ok<STOUT>

      error('MTEX:notIndexed:removed',['%s\n%s'], ...
        'notIndexed is no longer a class - an unindexed phase is a reference frame.', ...
        'Write notIndexedFrame instead, with the same arguments.');

    end

  end

  methods (Static = true)
    fr = loadobj(s)
  end

end
