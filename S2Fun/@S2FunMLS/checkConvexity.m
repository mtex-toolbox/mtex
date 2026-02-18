function iscvx = checkConvexity(S2F, v, idx)

% check for every @vector3d in v, if S2F.nodes(idx) contains neighbors in each
% quadrant w.r.t. the coordinate system centered at v, in polar coordiates

splitterCandidates = [vector3d.X; vector3d.Y; vector3d.Z];

% if idx is not sparse, then it is array of indice, meaning number of neighbors
%   nn is always the same
if ~issparse(idx) 

  [~, splitter_id] = min(abs(v.xyz), [], 2);
  splitter1 = cross(v, splitterCandidates.subSet(splitter_id)).normalize;
  splitter2 = cross(v, splitter1).normalize;

  % for all neighbors, determine its quadrant w.r.t. their center
  updown = dot(splitter1, S2F.nodes.subSet(idx)) >= 0;
  leftright = dot(splitter2, S2F.nodes.subSet(idx)) >= 0;

  % check for each quadrant if it contains nodes
  Q1 = any( updown &  leftright, 2);
  Q2 = any( updown & ~leftright, 2);
  Q3 = any(~updown &  leftright, 2);
  Q4 = any(~updown & ~leftright, 2);

  % check if all quadrants contain at least one node
  iscvx = all([Q1, Q2, Q3, Q4], 2);
  return;
end


% if idx is sparse, the number of neighbors is not constant across v 
[~, splitter_id] = min(abs(v.xyz), [], 2);
splitter1 = cross(v, splitterCandidates.subSet(splitter_id)).normalize;
splitter2 = cross(v, splitter1).normalize;

[grid_id, v_id] = find(idx');
updown    = dot(splitter1.subSet(v_id), S2F.nodes.subSet(grid_id)) >= 0;
leftright = dot(splitter2.subSet(v_id), S2F.nodes.subSet(grid_id)) >= 0;

% check for each quadrant if it contains nodes
Q1 =  accumarray(v_id,  updown &  leftright) > 0;
Q2 =  accumarray(v_id,  updown & ~leftright) > 0;
Q3 =  accumarray(v_id, ~updown &  leftright) > 0;
Q4 =  accumarray(v_id, ~updown & ~leftright) > 0;

% check if all quadrants contain at least one node
iscvx = all([Q1, Q2, Q3, Q4], 2);

end