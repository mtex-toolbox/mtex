function [q,omega] = getFundamentalRegion(S3G,q_ref)
% projects orientations to a fundamental region
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  CENTER - reference orientation
%
%% Output
%  q     - @quaternion
%  omega - rotational angle to reference orientation
%

%% get quaternions
if nargin == 1, q_ref = idquaternion;end
if length(S3G) > 1 || size(S3G.Grid,1) > 1
  q = quaternion(S3G);
else
  q = S3G.Grid;
end

%% no specimen symmetry
if length(S3G(1).SS) == 1 
    
  % may be we can skip something
  omega = abs(dot(q,q_ref));
  ind = omega < cos(20*degree);

  if ~any(ind),
    omega = 2*acos(max(1,omega));
    return;
  end

  % symetry elements
  qSym = quaternion(S3G(1).CS);
  
  % compute all distances to the fundamental regions
  omegaSym = dot_outer(q_ref .* qSym,q);
  
  % find fundamental region
  [omega,idy] = max(omegaSym);
  
  % project to fundamental region
  qSym = reshape(inverse(qSym),1,[]);
  q = q .* qSym(idy);
  
  % compute angle
  omega = 2*acos(min(1,omega));
  
%% with specimen symmetry
else 
  
  % symetry elements
  qcs = quaternion(S3G(1).CS);
  qss = quaternion(S3G(1).SS);
  
  % compute all distances to the fundamental regions
  omegaSym = dot_outer(qss * reshape(q_ref .* qcs,1,[]),q);
  
  % find fundamental region
  [omega,id] = max(omegaSym);
  if all(id==1), return;end
  
  % project to fundamental region
  qcs = reshape(inverse(qcs),1,[]);
  qss = reshape(inverse(qss),1,[]);
  [idss,idcs] = ind2sub([length(qss),length(qcs)],id);
  q = qss(idss) .* q .* qcs(idcs);
  
  % compute angle
  omega = 2*acos(min(1,omega));
end
