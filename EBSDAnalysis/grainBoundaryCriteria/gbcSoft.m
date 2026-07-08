classdef gbcSoft < grainBoundaryCriterion
% gbcSoft  soft misorientation-angle grain boundary criterion
%
% A smooth (error-function) version of the angle criterion: instead of a hard
% threshold the connectivity decreases gradually around it.
%
% Syntax
%
%   criterion = gbcSoft([10 2.5]*degree);
%   criterion = gbcSoft('threshold',[10 2.5]*degree);
%
%   out = criterion.eval(ebsd,i,j);
%
% Output (same convention as all grainBoundaryCriterion subclasses)
%   out ~ 1   no boundary (same grain)
%   out ~ 0   grain boundary
%
% The threshold is [t0 t1]: t0 is the centre misorientation angle, t1 the
% width of the transition. A scalar t is expanded to [t 0.5*t].

properties
  threshold = [10*degree, 5*degree]
end

methods

  function obj = gbcSoft(varargin)
    if nargin >= 1 && isnumeric(varargin{1}) && ~isempty(varargin{1})
      obj.threshold = varargin{1};
    elseif check_option(varargin,{'soft','threshold','angle'})
      obj.threshold = get_option(varargin,{'soft','threshold','angle'},obj.threshold);
    end
    if isscalar(obj.threshold)
      obj.threshold(2) = 0.5 * obj.threshold(1);
    end
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    out = zeros(size(i));
    rot = ebsd.rotations;
    phaseId = ebsd.phaseId;

    threshold = obj.threshold;
    if isscalar(threshold), threshold(2) = 0.5 * threshold(1); end

    for p = 1:numel(ebsd.phaseMap)

      cs = ebsd.CSList(p);

      % neighbouring cells with the same phase
      ind = phaseId(i) == p & phaseId(j) == p;
      if ~any(ind(:)), continue, end

      if cs.isIndexed
        o_Dl = orientation(rot(i(ind)),cs);
        o_Dr = orientation(rot(j(ind)),cs);
        % 1 - 0.5(1+erf(...)) : ~1 for small angles (same grain), ~0 above
        out(ind) = 1 - 0.5 * (1 + ...
          erf(2*(angle(o_Dl,o_Dr) - threshold(1)) ./ threshold(2)));
      else
        out(ind) = 1;
      end
    end
  end

end

end