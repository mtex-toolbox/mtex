function gB = reorder(gB,varargin)
% nicely reorder grain boundaries
%
% Deprecated. Boundary segments are stored in walk order by default, so
% there is nothing to reorder. Use grainBoundary/order to re-establish that
% invariant after modifying F directly.
%
% See also
% grainBoundary/order

warning(['gB.reorder is deprecated - boundary segments are already stored ' ...
  'in walk order. Use gB.order if you need to re-establish it.']);

gB = gB.order(varargin{:});
