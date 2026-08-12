function nn = candidate_count_S2(S2F)
% Number of KNN candidates fetched per center.
%
% A smooth support radius is not tied to the neighbor ranking, so more
% candidates than S2F.nn have to be fetched and the ones outside the local
% support are discarded via a zero weight. Without a smooth radius the support
% is defined by the farthest neighbor and no buffer is needed.

if S2F.use_smooth_delta
  nn = min(ceil(S2F.nn * S2F.candidateFactor), numel(S2F.nodes));
else
  nn = S2F.nn;
end

end
