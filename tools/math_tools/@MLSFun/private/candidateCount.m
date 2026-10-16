function nn = candidateCount(F)
% KNN candidates per center
%
% A smooth support radius is not tied to the neighbor ranking, so more
% candidates than nn are fetched and those outside the support get weight
% zero. Without it the farthest neighbor defines the support.

if F.use_smooth_delta
  nn = min(ceil(F.nn * F.candidateFactor),numel(F.nodes));
else
  nn = F.nn;
end

end
