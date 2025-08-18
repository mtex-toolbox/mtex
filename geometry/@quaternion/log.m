function out = log(q, varargin)
% the logarithmic map that translates a rotation into a tangent vector.
%
% Therefore it converts a given rotation, relative to a reference rotation, 
% into its corresponding tangent vector in the tangent space at the 
% reference. 
% Hence, the log-function computes the relative rotation.
%
% Syntax
%   v = log(q) % rotation vector with reference to the identical rotation
%   v = log(q,q_ref) % rotation vector with reference q_ref
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  v - @SO3TangentVector, @spinTensor
%
% See also
% quaternion/logm orientation/log vector3d/exp spinTensor/spinTensor

% extract data
if nargin>1 && isa(varargin{1},'quaternion')
  q_ref = varargin{1};
else
  q_ref = quaternion.id;
end
tS = SO3TangentSpace.extract(varargin);


% if reference point for tangential space is given - rotate
if q_ref ~= quaternion.id
  if tS.isRight
    %q = times(q_ref', q,1);
    q = itimes(q_ref, q,true); % inv(q_ref) .* q 
  else
    %q = q .* q_ref';
    q = itimes(q, q_ref,false); % q .* inv(q_ref)
  end
end

% the logarithm with respect to the identity 
a = min(q.a,1);
omega = 2 * sign(a) .* acos(abs(a));
denum = sqrt(1-a.^2);
denum(denum == 0) = inf;
omega = omega ./ denum;

% make it askew symmetric matrix / spin tensor
if tS.isSpinTensor
  
  M = zeros([3,3,size(q)]);

  M(2,1,:) =  q.d(:); M(1,2,:) = -M(2,1,:);
  M(3,1,:) = -q.c(:); M(1,3,:) = -M(3,1,:); 
  M(3,2,:) =  q.b(:); M(2,3,:) = -M(3,2,:);

  % make it a spinTensor
  out = spinTensor(omega .* M);

else % make it a vector
  
  v = vector3d(omega .* q.b, omega .* q.c, omega .* q.d);
  out = SO3TangentVector(v,q_ref,tS);

end


