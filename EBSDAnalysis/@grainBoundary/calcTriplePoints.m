function tP = calcTriplePoints(gB,grainsPhaseId)

% compute triple points
I_VF = gB.I_VF;
I_VG = (I_VF * gB.I_FG)==2;
% triple points are those with exactly 3 neigbouring grains and 3
% boundary segments
itP = full(sum(I_VG,2)==3 & sum(I_VF,2)==3);
[tpGrainId,~] = find(I_VG(itP,:).');
tpGrainId = reshape(tpGrainId,3,[]).';
tpPhaseId = full(grainsPhaseId(tpGrainId));

% compute ebsdId
% first step: compute faces at the triple point
% clean up incidence matrix
%I_FD(~any(I_FD,2),:) = [];
% incidence matrix between triple points and voronoi cells
%I_TD = I_VF(itP,:) * I_FD;
[tPBoundaryId,~] = find(I_VF(itP,:).');
tPBoundaryId = reshape(tPBoundaryId,3,[]).';

tP = triplePointList(find(itP),gB.V(itP,:),...
  tpGrainId,tPBoundaryId,tpPhaseId,gB.phaseMap,gB.CSList);
      
end

