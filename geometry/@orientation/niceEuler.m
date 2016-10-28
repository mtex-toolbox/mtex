function varargout = niceEuler(o,varargin)
% orientation to euler angle
%
% Description
% calculates the Euler angle for a rotation |q|
%
% Syntax
%   [alpha,beta,gamma] = niceEuler(ori) - 
%   [phi1,Phi,phi2] = niceEuler(ori,'Bunge') -
%   euler = Euler(ori,'Bunge') -
%
% Input
%  ori - @orientation
%
% Output
%  alpha, beta, gamma  - Matthies
%  phi1, Phi, phi2     - BUNGE
%
% Options
%  ABG, ZYZ   - Matthies (alpha,beta,gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi, Phi, phi2) convention
%
% See also
% quaternion/Rodrigues

% symmetrise
osym = symmetrise(o);

% compute Euler angles
[phi1,Phi,phi2] = Euler(osym,varargin{:});

% check for fundamental region
[max_phi1,max_Phi,max_phi2] = fundamentalRegionEuler(o.CS,o.SS,varargin);

penalty = phi1+Phi+phi2;

penalty(phi1>max_phi1) = 100;
penalty(Phi>max_Phi) = 100;
penalty(phi2>max_phi2) = 100;

% check for integers
ind = abs(round(phi1/degree)-phi1/degree) > 0.01 | ...
  abs(round(phi2/degree)-phi2/degree) > 0.01 | ...
  abs(round(Phi/degree)-Phi/degree) > 0.01;

penalty(ind) = penalty(ind) + 10;

% take the best Euler angles
[~,i] = min(penalty,[],1);

osym = osym.subSet(sub2ind(size(osym),i,1:size(osym,2)));

% return result
[varargout{1:nargout}] = Euler(osym,varargin{:});
