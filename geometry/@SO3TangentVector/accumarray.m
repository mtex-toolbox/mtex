function a = accumarray(subs,v,varargin)
% accumarray for SO3TangentVector's
%
% Syntax
%   v = accumarray(subs,v)   
%
% Input
%  subs - 
%  v - @SO3TangentVector 
%
% Output
%  v - @SO3TangentVector

% ensure compatible tangent spaces
groupcheck = @(r) all( angle(r,r(1))<1e-5 ,'all' );
e = accumarray(subs, (1:numel(v.rot))', [],  @(ii) groupcheck(v.rot(ii)));
if ~all(e)
  error(['Trying to add some tangent vectors of different tangent spaces. ' ...
         'Sometimes the rotations (which define the tangent spaces) do not coincide.'])
end

% Computation
a = accumarray@vector3d(subs,v,varargin{:});
a.rot = accumarray(subs,v.rot);

end