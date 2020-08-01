function [q,ics1,ics2] = project2FRCS2_ref(q,CS1,CS2,q_ref)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS1,CS2,q_ref)  % misorientation to FR
%   around q_ref
%
% Input
%  q        - list of @quaternion
%  q_ref    - a single reference @quaternion
%  CS1, CS2 - crystal @symmetry
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

% consider only proper rotations
CS1 = CS1.properGroup;
CS2 = CS2.properGroup;

% project to fundamental region
% note: d(CS2 * q * CS1, q_ref) = d(q, inv(CS2) * q_ref * inv(CS1))
q_refSym = mtimes(times(inv(CS2.rot),q_ref,1),inv(CS1.rot),0); 

if length(q)>100000
  
  % maybe q_ref has some multiplicity and we can save some time
  [q_refSym,m,~] = unique(q_refSym,'antipodal','noSymmetry'); 
  [ics2,ics1] = ind2sub([numSym(CS2),numSym(CS1)],m);

  % take the minimum distances to all symmetric equivalent orientations
  [~,i12] = max(abs(dot_outer(q,q_refSym,'noSymmetry','ignoreInv')),[],2);
  ics1 = ics1(i12);
  ics2 = ics2(i12);
  
else
    
  % take the minimum distances to all symmetric equivalent orientations
  [~,ind] = max(abs(dot_outer(q,q_refSym,'noSymmetry','ignoreInv')),[],2);  
  [ics2,ics1] = ind2sub([numSym(CS2),numSym(CS1)],ind);
  
end

% project to fundamental region
q = times(times(reshape(CS2.rot.subSet(ics2),size(q)), q, 1), ...
  reshape(CS1.rot.subSet(ics1),size(q)),0);

end

% some testing code
function test
 cs1 = crystalSymmetry('432');
 cs2 = crystalSymmetry('32');
 
 ori_ref = orientation.rand(cs1,cs2);
 ori = orientation.rand(1000 ,cs1,cs2);
 ori_proj = project2FundamentalRegion(ori,ori_ref);
 figure(1)
 histogram((angle(ori_proj,ori_ref,'noSymmetry')./degree))
 figure(2)
 histogram((angle(ori,ori_ref)./degree))
 figure(3)
  histogram((angle(ori,ori_ref,'noSymmetry')./degree))
 end