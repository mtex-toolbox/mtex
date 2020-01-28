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

if ismember(ori.SS.id, [1,2])
  ori = project2FundamentalRegion@quaternion(ori,ori.CS,varargin{:});
else
  if ori.antipodal, ap = {'antipodal'}; else, ap = {}; end
  CS = ori.CS; SS = ori.SS;
  ori = project2FundamentalRegion@quaternion(ori,CS,SS,ap{:},varargin{:});

  % ensure result is of type orientation
  if ~isa(ori,'orientation')
    ori = orientation(ori,CS,SS,ap{:});
  end
  
end
