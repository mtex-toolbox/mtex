function [q,omega] = getFundamentalRegion(o,q_ref)
% projects orientations to a fundamental region
%
%% Input
%  o     - @orientation
%  q_ref - reference @quaternion
%
%% Output
%  q     - @quaternion
%  omega - rotational angle to reference orientation
%

%% get quaternions
if nargin == 1, q_ref = idquaternion;end
q = o.quaternion;

%% no specimen symmetry
if length(o.ss) == 1 
    
  % may be we can skip something
  omega = abs(dot(q,q_ref));
  ind = omega < cos(20*degree);

  if ~any(ind),
    omega = 2*acos(min(1,omega));
    return;
  end

  % symetry elements
  qSym = quaternion(o.cs);
  
  % compute all distances to the fundamental regions
  omegaSym = dot_outer(q_ref .* qSym,q);
  
  % find fundamental region
  [omega,idy] = max(omegaSym,[],1);
  
  % project to fundamental region
  qSym = inverse(qSym);
  q = q .* reshape(qSym(idy),size(q));
  
  % compute angle
  omega = 2*acos(min(1,omega));
  
%% with specimen symmetry
else 
  
  % symetry elements
  qcs = quaternion(o.cs);
  qss = quaternion(o.ss);
  
  % compute all distances to the fundamental regions
  omegaSym = dot_outer(qss * reshape(q_ref .* qcs,1,[]),q);
  
  % find fundamental region
  [omega,id] = max(omegaSym);
  if all(id==1), return;end
  
  % project to fundamental region
  qcs = reshape(inverse(qcs),1,[]);
  qss = reshape(inverse(qss),1,[]);
  [idss,idcs] = ind2sub([length(qss),length(qcs)],id);
  q = reshape(qss(idss),size(q)) .* q .* reshape(qcs(idcs),size(q));
  
  % compute angle
  omega = 2*acos(min(1,omega));
end
