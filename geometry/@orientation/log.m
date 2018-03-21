function v = log(ori,ori_ref,varargin)
% the misorientation vector in crystal coordinates 
%
% Description
%
% Mathematically, misorientation vector is the the inverse of the
% exponential map, hence the name log.
%
% Syntax
%   v = log(ori)
%
%   % the misorientation vector in crystal coordinats 
%   v = log(ori,ori_ref)
%
%   % the misorientation vector in specimen coordinats
%   r = ori_ref .* v
%
%
% Input
%  ori - @orientation
%  ori_ref - @orientation
%
% Output
%  v - @vector3d
%
% See also
% 

if nargin > 2 && check_option(varargin,'ll')
  ori_ref = orientation(ori_ref,ori.CS,ori.SS);
  v = axis(ori,ori_ref) .* angle(ori,ori_ref);
  return
end

if nargin >= 2

  if isa(ori.CS,'crystalSymmetry')
    ori = inv(ori_ref) .* ori;
    % we should not change the reference frame of the reference
    % orientation
    ori.SS = specimenSymmetry;
  else    
    ori = ori .* inv(ori_ref);
    % we should not change the reference frame of the reference
    % orientation
    ori.CS = specimenSymmetry;
  end
    
end

ori = project2FundamentalRegion(ori);

v = Miller(log@quaternion(ori),ori.CS);

if nargin>2 && check_option(varargin,'left')
  v = ori_ref .* v;
end

end

function test
  % some testing code
  
  cs = crystalSymmetry('321');
  ori1 = orientation.rand(cs);
  ori2 = orientation.rand(cs);

  v = log(ori2,ori1);
  
  % this should be the same
  [norm(v),angle(ori1,ori2)] ./ degree
  
  % and this too
  [ori1 * orientation('axis',v,'angle',norm(v)) ,project2FundamentalRegion(ori2,ori1)]
  
  % in specimen coordinates
  r = log(ori2,ori1,'left');
    
  % now we have to multiply from the left
  [rotation('axis',r,'angle',norm(v)) * ori1 ,project2FundamentalRegion(ori2,ori1)]
  
  % the following output should be constant
  % gO = log(ori1,ori2.symmetrise) % but not true for this
  % gO = log(ori1.symmetrise,ori2) % true for this
  %
  % gO = ori2.symmetrise .* log(ori1,ori2.symmetrise) % true for this
  % gO = ori2 .* log(ori1.symmetrise,ori2) % true for this
  
end



