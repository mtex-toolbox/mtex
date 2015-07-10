function ori = project2FundamentalRegion(ori,varargin)
% projects orientation to a fundamental region
%
% Syntax
%   ori = project2FundamentalRegion(ori,rot_ref)
%
% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%
% Output
%  ori     - @orientation
%  omega   - rotational angle to reference rotation
%

if ori.antipodal, ap = {'antipodal'}; else ap = {}; end
q = project2FundamentalRegion(quaternion(ori),ori.CS,ori.SS,ap{:},varargin{:});

ori = orientation(q,ori.CS,ori.SS,ap{:});