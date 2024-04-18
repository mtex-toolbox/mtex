function tP = calcTriplePoints(gB)
%
% Input
%  gB - @grainBoundary


% list of phaseIds ordered as grainIds
grainId = gB.grainId;
grainPhaseId = zeros(max(grainId(:)),1);
grainPhaseId(grainId(grainId>0)) = gB.phaseId((grainId>0));

% compute triple points
[i,~,f] = find(gB.F);
I_VF = sparse(f,i,1,size(gB.V,1),size(gB.F,1));
I_VG = (I_VF * gB.I_FG)==2;
% triple points are those with exactly 3 neighboring grains and 3
% boundary segments
itP = full(sum(I_VG,2)==3 & sum(I_VF,2)==3);
[tpGrainId,~] = find(I_VG(itP,:).');
tpGrainId = reshape(tpGrainId,3,[]).';
tpPhaseId = full(grainPhaseId(tpGrainId));

% compute ebsdId
% first step: compute faces at the triple point
% clean up incidence matrix
%I_FD(~any(I_FD,2),:) = [];
% incidence matrix between triple points and Voronoi cells
%I_TD = I_VF(itP,:) * I_FD;
[tPBoundaryId,~] = find(I_VF(itP,:).');
tPBoundaryId = reshape(tPBoundaryId,3,[]).';

% get the three end vertices
iV = reshape(gB.F(tPBoundaryId,:),[],6).';
% TODO: the repmat can be removed in new versions of MATLAB
iV = reshape(iV(iV ~= repmat(find(itP).',size(iV,1),1)).',3,[]).';

tP = triplePointList(find(itP),gB.V,...
  tpGrainId,tPBoundaryId,tpPhaseId,iV,gB.phaseMap,gB.CSList);

end

