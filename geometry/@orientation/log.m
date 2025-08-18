function v = log(ori,varargin)
% the logarithmic map that translates a orientation into a tangent vector.
%
% Therefore it converts a given orientation, relative to a reference 
% orientation, into its corresponding tangent vector in the tangent space 
% at the reference. 
%
% Hence, the log-function computes the relative orientation. This can also 
% be interpreted as misorientation vector between two orientations, which
% is measured in the tangent space.
% 
% The misorientation vector can also be seen as the projection of an
% orientation onto the tangential space of the orientation space centered
% at the orientation |ori_ref|. The inverse mapping from the tangential
% space onto the orientation space is the exponential map 
% |<SO3TangentVector.exp.html exp>|.
%
% Syntax
%   v = log(ori)
%   v = log(ori,ori_ref,SO3TangentSpace.rightVector) 
%
% Input
%  ori,ori_ref - @orientation
%
% Output
%  v - @SO3TangentVector, @spinTensor
%
% Example
%   % compute misorientation vector in crystal coordinates
%   v = Miller(log(mori,SO3TangentSpace.rightVector),mori.CS)
%
% See also
% orientation/logm quaternion/log vector3d/exp Miller/exp

if check_option(varargin,'noSymmetry')
  v = log@quaternion(ori,varargin{:});
  return
end

% extract data
if nargin>1 && isa(varargin{1},'quaternion')
  ori_ref = varargin{1};
else
  ori_ref = orientation.id(ori.CS,ori.SS);
end
tS = SO3TangentSpace.extract(varargin);



if ori_ref ~= quaternion.id
  if tS.isLeft
    orin = ori .* inv(ori_ref);
    % we should not change the reference frame of the reference orientation
    ori = orientation(orin,specimenSymmetry,ori.SS);
  else
    orin = inv(ori_ref) .* ori;
    % we should not change the reference frame of the reference orientation
    ori = orientation(orin,ori.CS,specimenSymmetry);
  end
end

if isa(ori,'orientation')
  ori = project2FundamentalRegion(ori);
end

% compute logarithmic map without symmetries
v = log@quaternion(ori);

% construct output
if tS.isSpinTensor
  v = spinTensor(v);
else
  v = SO3TangentVector(v,ori_ref,tS);
end

end
