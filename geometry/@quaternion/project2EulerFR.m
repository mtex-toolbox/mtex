function [phi1,Phi,phi2] = project2EulerFR(q,CS1,CS2)
% projects quaternions to a fundamental region
%
% Syntax
%   project2EulerFR(q,CS)       % to FR around idquaternion
%   project2EulerFR(q,CS,q_ref) % to FR around reference rotation
%   project2EulerFR(q,CS1,CS2)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - reference @quaternion single or size(q) == size(q_ref)
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

[max_phi1,max_Phi,max_phi2] = getFundamentalRegion(CS1,CS2);
%ori = ori.project2FundamentalRegion;
   
if max_Phi<pi
  [axes,~] = DSO3.CS.getMinAxes;
  ia = find(isnull(dot(axes,zvector)),1,'first');
  [~,Phi,~] = Euler(ori);
  ori(Phi > pi/2) = ori(Phi > pi/2) * orientation('axis',axes(ia),'angle',pi,DSO3.CS,DSO3.CS);
end
   
