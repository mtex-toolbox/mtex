function tP = calcTriplePoints(gB,varargin)
%
% Input
%  gB - @grainBoundary
%
% Output
%  tP - @triplePointList
%


if 1 % the fast implementation

  % list of phaseIds ordered as grainIds
grainId = gB.grainId;
grainPhaseId = zeros(max(grainId(:)),1);
grainPhaseId(grainId(grainId>0)) = gB.phaseId((grainId>0));

F  = gB.F;
nV = size(gB.allV,1);
nF = size(F,1);

% Vertex face-degree straight from the face list (nF × 2 vertex ids), without
% building the full nV × nF incidence matrix. A triple point must have
% face-degree exactly 3, so this alone selects the candidate vertices. This
% avoids the expensive sparse(f,i,1,nV,nF) assembly, which dominated the
% runtime on large maps.
vFaceDeg = accumarray(F(:), 1, [nV 1]);
cand     = find(vFaceDeg == 3);                 % candidate vertex ids

% Build the vertex-face incidence only for the candidate vertices: for each of
% the 2 columns of F, keep the faces whose endpoint is a candidate. I_VFc is
% (#cand × nF) and cheap because #cand << nV.
vpos = zeros(nV,1); vpos(cand) = 1:numel(cand); % candidate vertex -> row
r = []; c = [];
for k = 1:2
  hit = vpos(F(:,k)) > 0;                        % faces whose k-th vertex is a candidate
  r = [r; vpos(F(hit,k))];   
  c = [c; find(hit)];        
end
I_VFc = sparse(r, c, 1, numel(cand), nF);

% grains meeting each candidate vertex: faces of the vertex belonging to each
% grain; a real triple-point/grain incidence is where that count == 2
I_VGc = (I_VFc * gB.I_FG) == 2;

% keep candidates that also touch exactly 3 grains
isTP  = full(sum(I_VGc,2) == 3);
% itP must stay a column even when numel(cand)==1: MATLAB's scalar
% logical indexing (cand(isTP) with both 1x1) collapses to 0x0 instead
% of 0x1 when isTP is false, unlike the Nx1 case for any other N.
itP   = reshape(cand(isTP),[],1);               % triple-point vertex ids
I_VG  = I_VGc(isTP,:);                          % (#tp × nG) grain incidence
I_VFt = I_VFc(isTP,:);                          % (#tp × nF) face incidence

% grain ids per triple point (3 each)
[tpGrainId,~] = find(I_VG.');
tpGrainId = reshape(tpGrainId,3,[]).';
tpPhaseId = full(grainPhaseId(tpGrainId));

% boundary-segment ids per triple point (3 each)
[tPBoundaryId,~] = find(I_VFt.');
tPBoundaryId = reshape(tPBoundaryId,3,[]).';

% get the three end vertices (the other end of each of the 3 segments)
iV = reshape(gB.F(tPBoundaryId,:),[],6).';
% TODO: the repmat can be removed in new versions of MATLAB
iV = reshape(iV(iV ~= repmat(itP.',size(iV,1),1)).',3,[]).';

tP = triplePointList(itP,gB.allV,...
  tpGrainId,tPBoundaryId,tpPhaseId,iV,gB.phaseMap,gB.CSList);

else % this is the slow more understandable route
  
  % list of phaseIds ordered as grainIds
  grainId = gB.grainId;
  grainPhaseId = zeros(max(grainId(:)),1);
  grainPhaseId(grainId(grainId>0)) = gB.phaseId((grainId>0));
  
  % compute triple points
  [i,~,f] = find(gB.F);
  I_VF = sparse(f,i,1,size(gB.allV,1),size(gB.F,1));
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

  tP = triplePointList(find(itP),gB.allV,...
    tpGrainId,tPBoundaryId,tpPhaseId,iV,gB.phaseMap,gB.CSList);

end

