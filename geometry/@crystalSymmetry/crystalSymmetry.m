classdef crystalSymmetry
% the name a crystal frame was called by before ADR 0008
%
% A reference frame carries the point group now, so a crystal symmetry *is*
% a <crystalFrame.crystalFrame.html |crystalFrame|> and this class holds
% nothing. It exists so that MATLAB finds a name for the objects in a file
% written before the change: |loadobj| converts what it reads into a crystal
% frame. Constructing one errors and names the frame instead.
%
% See also
% crystalFrame specimenSymmetry referenceFrame

  methods

    function cs = crystalSymmetry(varargin) %#ok<STOUT>

      error('MTEX:crystalSymmetry:removed',['%s\n%s'], ...
        'crystalSymmetry is no longer a class - a reference frame carries the point group.', ...
        'Write crystalFrame instead, with the same arguments.');

    end

  end

  methods (Static = true)
    fr = loadobj(s)
  end

end
