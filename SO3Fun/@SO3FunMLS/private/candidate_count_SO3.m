function nn = candidate_count_SO3(SO3F)
% Number of KNN candidates fetched per center.
%
% A smooth support radius is not tied to the neighbor ranking, so more
% candidates than SO3F.nn have to be fetched and the ones outside the local
% support are discarded via a zero weight. Without a smooth radius the support
% is defined by the farthest neighbor and no buffer is needed.

if SO3F.use_smooth_delta
  nn = min(ceil(SO3F.nn * SO3F.candidateFactor), numel(SO3F.nodes));
else
  nn = SO3F.nn;
end

end
