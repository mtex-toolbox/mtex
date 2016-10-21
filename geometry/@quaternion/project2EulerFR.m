function [phi1,Phi,phi2] = project2EulerFR(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   [phi1,Phi,phi2] = project2EulerFR(q,CS)       % to FR around idquaternion
%   [phi1,Phi,phi2] = project2EulerFR(q,CS,'Bunge')  % to FR around idquaternion
%   [phi1,Phi,phi2] = project2EulerFR(q,CS,q_ref) % to FR around reference rotation
%   [phi1,Phi,phi2] = project2EulerFR(q,CS1,CS2)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - reference @quaternion single or size(q) == size(q_ref)
%
% Output
%  phi1,Phi,phi2 - Euler angles
%

[~,Phi,~] = Euler(q);

isPerpZ1 = isnull(dot(CS1.axis,zvector)) & ~isnull(angle(CS1));
isPerpZ2 = isnull(dot(CS2.axis,zvector)) & ~isnull(angle(CS2));
ind = Phi > pi/2;

s = substruct('()',{ind});
if any(isPerpZ1)
  q = subsasgn(q,s,q.subSet(ind) * CS1.subSet(find(isPerpZ1,1)));
elseif any(isPerpZ2)
  q = subsasgn(q,s,CS2.subSet(find(isPerpZ2,1)) * q.subSet(ind));
end

[maxphi1,~,maxphi2] = fundamentalRegionEuler(CS1,CS2);

% convert to euler angles angles
[phi1,Phi,phi2] = Euler(q,varargin{:});

phi1 = mod(phi1,maxphi1);
phi2 = mod(phi2,maxphi2);
