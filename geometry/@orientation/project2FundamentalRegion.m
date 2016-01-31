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

if length(ori.SS) == 1 
  q = project2FundamentalRegion(quaternion(ori),ori.CS,varargin{:});
else
  if ori.antipodal, ap = {'antipodal'}; else ap = {}; end
  q = project2FundamentalRegion(quaternion(ori),ori.CS,ori.SS,ap{:},varargin{:});
end

% set values
sa = size(ori.a);
ori.a = reshape(q.a,sa);
ori.b = reshape(q.b,sa);
ori.c = reshape(q.c,sa);
ori.d = reshape(q.d,sa);
%ori = orientation(q,ori.CS,ori.SS);