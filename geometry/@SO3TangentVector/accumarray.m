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

% ensureCompatibleTangentSpaces
groupcheck = @(r) all( angle(r,r(1))<1e-5 ,'all' );
e = accumarray(subs, (1:numel(v.rot))', [],  @(ii) groupcheck(v.rot(ii)));
if ~all(e)
  error('The tangent spaces of some tangent vectors added together do not coincide.')
end

% Computation
a = accumarray@vector3d(subs,v,varargin{:});
a.rot = accumarray(subs,v.rot);

end