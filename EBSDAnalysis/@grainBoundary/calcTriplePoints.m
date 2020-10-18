function tP = calcTriplePoints(gB,V,grainsPhaseId)

% compute triple points
[i,~,f] = find(gB.F);
I_VF = sparse(f,i,1,size(V,1),size(gB.F,1));
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

% get the three end vertices
iV = reshape(gB.F(tPBoundaryId,:),[],6).';
iV = reshape(iV(iV ~= find(itP).').',3,[]).';

tP = triplePointList(find(itP),V,...
  tpGrainId,tPBoundaryId,tpPhaseId,iV,gB.phaseMap,gB.CSList);

end

