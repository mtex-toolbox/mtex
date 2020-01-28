function rot = project2FundamentalRegion(rot,varargin)
% projects rotation to a fundamental region
%
% Syntax
%   project2FundamentalRegion(rot,CS,rot_ref)
%
% Input
%  rot     - @rotation
%  CS1,CS2 - crystal @symmetry
%  rot_ref - reference @rotation
%
% Output
%  rot     - @rotation
%  omega   - rotational angle to reference rotation
%

rot = project2FundamentalRegion@quaternion(rot,varargin{:});

% ensure the result is again a rotation
if ~isa(rot,'rotation'), rot = rotation(rot); end