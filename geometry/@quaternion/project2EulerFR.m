function [phi1,Phi,phi2] = project2EulerFR(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   [phi1,Phi,phi2] = project2EulerFR(q,CS)       % Bunge fundamental region
%   [alpha,beta,gamma] = project2EulerFR(q,CS,'Matthies')  % Matthies fundamental region
%   [phi1,Phi,phi2] = project2EulerFR(q,CS1,CS2)  % misorientations
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%
% Output
%  phi1,Phi,phi2 - Euler angles
%

% get the fundamental region
[maxphi1,maxPhi,maxphi2] = fundamentalRegionEuler(CS1,CS2);

% symmetrise
q_sym = (CS2.rotation_special * quaternion(q)).' * CS1.rotation_special;
q_sym = reshape(q_sym,length(q),[]);
[phi1_sym,Phi_sym,phi2_sym] = Euler(q_sym,varargin{:});

% the simple part
phi1_sym = mod(phi1_sym,2*pi/CS2.multiplicityZ);
phi2_sym = mod(phi2_sym,2*pi/CS1.multiplicityZ);

% check which are inside the fundamental region
isInside = phi1_sym <= maxphi1 & phi2_sym <= maxphi2 & Phi_sym <= maxPhi;

% take the first one
[~,rowPos] = max(isInside,[],2);
ind = sub2ind(size(phi1_sym),1:length(q),rowPos.');

phi1 = reshape(phi1_sym(ind),size(q));
Phi = reshape(Phi_sym(ind),size(q));
phi2 = reshape(phi2_sym(ind),size(q));
