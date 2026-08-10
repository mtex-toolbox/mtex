classdef gbcAngle < grainBoundaryCriterion
% gbcAngle Misorientation-angle grain boundary criterion
%
% Syntax
%
%   criterion = gbcAngle;
%   criterion = gbcAngle(10*degree);
%   criterion = gbcAngle('threshold',10*degree);
%
%   % a high and a low angle threshold
%   criterion = gbcAngle([10*degree 2*degree]);
%
%   % one threshold per phase, in the order of ebsd.CSList
%   criterion = gbcAngle({10*degree, 15*degree, [10 2]*degree});
%
%   out = criterion.evaluate(ebsd,i,j);
%
% Output
%
%   out = 1    no boundary <--> angle < low
%   out = 0.5  low-angle boundary <--> low <= angle < high
%   out = 0    high-angle boundary <--> angle >= high
%

properties
  threshold = 15*degree
end

methods

  function obj = gbcAngle(varargin)
    if nargin == 1 && (isnumeric(varargin{1}) || iscell(varargin{1}))
      obj.threshold = varargin{1};
    elseif check_option(varargin,{'angle','threshold'})
      obj.threshold = get_option(varargin,{'angle','threshold'},obj.threshold);
    end
  end

end

methods (Access = protected)

  function t = phaseThreshold(obj,p,numPhases)
    % the threshold to apply to phase p
    %
    % A cell threshold is one entry per phase, in the order of ebsd.CSList.
    % Anything else is a single threshold shared by all phases.

    t = obj.threshold;
    if ~iscell(t), return; end

    assert(numel(t) == numPhases, ...
      ['The number of thresholds does not match the number of phases. ' ...
      'Give one threshold per entry of ebsd.CSList, i.e. %d in total, ' ...
      'or a single threshold for all phases.'],numPhases);

    t = t{p};
  end

  function out = doEvaluate(obj,ebsd,i,j)
          
    out = zeros(size(i));
    rot = ebsd.rotations;
    phaseId = ebsd.phaseId;

    % all misrotations
    mori = itimes(rot(i),rot(j),1);

    for p = 1:numel(ebsd.phaseMap)

      cs = ebsd.CSList(p);

      % neighboring cells (i,j) with the same phase
      ind = phaseId(i) == p & phaseId(j) == p;

      if ~any(ind(:)), continue, end

      % check for the grain boundary criterion
      if cs.isIndexed
        d = max(abs(dot_outer(mori(ind),cs.properGroup.rot)),[],2);
        out(ind) = mean(d > cos(obj.phaseThreshold(p,numel(ebsd.phaseMap))/2),2);
      else
        out(ind) = 1;        
      end
    end
  end

end

end
