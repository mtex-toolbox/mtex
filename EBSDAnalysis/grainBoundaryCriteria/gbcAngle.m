classdef gbcAngle < grainBoundaryCriterion
% gbcAngle Misorientation-angle grain boundary criterion
%
% Syntax
%
%   criterion = gbcAngle;
%   criterion = gbcAngle(10*degree);
%   criterion = gbcAngle('threshold',10*degree);
%
%   out = criterion.evaluate(ebsd,i,j);
%
% Output
%
%   out = 0    no boundary
%   out = 0.5  low-angle boundary
%   out = 1    high-angle boundary
%
% If threshold is scalar, the current behavior is preserved:
%
%   out = mean(d > cos(threshold/2),2)
%
% If threshold has two entries [low high], then
%
%   angle < low         -> 0
%   low <= angle < high -> 0.5
%   angle >= high       -> 1

properties
  threshold = 10*degree
end

methods

  function obj = gbcAngle(varargin)

    if nargin == 1 && isnumeric(varargin{1})
      obj.threshold = varargin{1};
    elseif check_option(varargin,{'angle','threshold'})
      obj.threshold = get_option(varargin,{'angle','threshold'},obj.threshold);
    end
    
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)
          
    out = zeros(size(i));
    rot = ebsd.rotations;

    for p = 1:numel(ebsd.phaseMap)

      cs = ebsd.CSList(p);

      % neighboring cells (i,j) with the same phase
      ind = ebsd.phaseId(i) == p & ebsd.phaseId(j) == p;

      if ~any(ind(:)), continue, end

      % check for the grain boundary criterion
      if cs.isIndexed
        mori = itimes(rot(i(ind)),rot(j(ind)),1);
        d = max(abs(dot_outer(mori,cs.properGroup.rot)),[],2);
        out(ind) = mean(d > cos(obj.threshold/2),2);
      else
        out(ind) = 1;        
      end
    end
  end

end

end