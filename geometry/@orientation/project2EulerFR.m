function varargout = project2EulerFR(ori,varargin)
% projects orientation to a fundamental region
%
% Syntax
%   [phi1, Phi, phi2] = project2FundamentalRegion(ori,'Bunge')
%
% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%
% Output
%  phi1, Phi, phi2 - Euler angles
%

[varargout{1:nargout}] = project2EulerFR@quaternion(ori,ori.CS,ori.SS,varargin{:});
