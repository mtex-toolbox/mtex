function tP = calcQuadruplePoints(gB,grainsPhaseId)

%gB=grains.boundary;
%I_VF = gB.I_VF;
%I_VG = (I_VF * gB.I_FG)==2;
%itP = full(sum(I_VG,2)==4 & sum(I_VF,2)==4);
%qp=find(itP);

% compute triple points
I_VF = gB.I_VF;
I_VG = (I_VF * gB.I_FG)==2;
% quadruple points are those with exactly 4 neigbouring grains and 4
% boundary segments
iqP = full(sum(I_VG,2)==4 & sum(I_VF,2)==4);
[tpGrainId,~] = find(I_VG(iqP,:).');
tpGrainId = reshape(tpGrainId,4,[]).';
tpPhaseId = reshape(full(grainsPhaseId(tpGrainId)),[],4);

% compute ebsdId
% first step: compute faces at the quadruple point
% clean up incidence matrix
%I_FD(~any(I_FD,2),:) = [];
% incidence matrix between triple points and voronoi cells
%I_TD = I_VF(itP,:) * I_FD;
[tPBoundaryId,~] = find(I_VF(iqP,:).');
tPBoundaryId = reshape(tPBoundaryId,4,[]).';

tP = quadruplePointList(find(iqP),gB.V(iqP,:),...
  tpGrainId,tPBoundaryId,tpPhaseId,gB.phaseMap,gB.CSList);
      
end

