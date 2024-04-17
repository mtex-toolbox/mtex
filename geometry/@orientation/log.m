function v = log(ori,ori_ref,varargin)
% misorientation vector between two orientations 
%
% The misorientation vector can also be seen as the projection of an
% orientarion onto the tangential space of the orientation space centered
% at the orientation |ori_ref|. The inverse mapping from the tantential
% space onto the orientation space is the exponential map |<Miller.exp.html
% exp>|.
%
% Syntax
%   m = log(mori) % the misorientation vector in crystal coordinats 
%
%   % the misorientation vector in crystal coordinats 
%   m = log(ori,ori_ref)
%
%   % the misorientation vector in specimen coordinats
%   v = log(ori,ori_ref, SO3TangentSpace.leftVector)
%   v = ori_ref .* m
%
% Input
%  mori - misorientation
%  ori - @orientation
%  ori_ref - @orientation
%
% Output
%  m - @Miller
%  v - @vector3d
%
% See also
% orientation/logm vector3d/exp Miller/exp

if check_option(varargin,'noSymmetry')
  v = log@quaternion(ori,ori_ref,varargin{:});
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

if nargin>2
  tS = SO3TangentSpace.extract(varargin{:},SO3TangentSpace.rightVector);
  
  if tS.isLeft, v = ori_ref .* v; end
end

end
