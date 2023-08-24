function rot = exp(v,rot_ref,varargin)
% rotation vector to rotation
%
% Syntax
%   rot = exp(v,ori_ref)  % orientation update
%
% Input
%  v - @SO3TangentVector rotation vector in specimen coordinates
%  ori_ref - @orientation @rotation
%
% Output
%  rot  - @rotation
%
% See also
% vector3d/exp orientation/log


tS = v.tangentSpace;
if ( strcmp(tS,'right') && check_option(varargin,'left') ) || ...
      ( strcmp(tS,'left') && check_option(varargin,'right') )
  error(['The vectors are elements of one representation of the tangent ' ...
         'space and you try to compute the exponential mapping w.r.t. a ' ...
         'other representation of the tangent space.']);
end

rot = exp@vector3d(v,rot_ref,varargin{:},tS);

end