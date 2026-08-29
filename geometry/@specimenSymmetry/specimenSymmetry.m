classdef specimenSymmetry
% the name a specimen frame was called by before ADR 0008
%
% A reference frame carries the point group now, so a specimen symmetry *is*
% a <specimenFrame.specimenFrame.html |specimenFrame|> and this class holds
% nothing. It exists so that MATLAB finds a name for the objects in a file
% written before the change: |loadobj| converts what it reads into a
% specimen frame. Constructing one errors and names the frame instead.
%
% See also
% specimenFrame crystalSymmetry referenceFrame

  methods

    function ss = specimenSymmetry(varargin) %#ok<STOUT>

      error('MTEX:specimenSymmetry:removed',['%s\n%s'], ...
        'specimenSymmetry is no longer a class - a reference frame carries the point group.', ...
        'Write specimenFrame instead, with the same arguments.');

    end

  end

  methods (Static = true)
    fr = loadobj(s)
  end

end
