function c = cumsum(v,varargin)
% cumulative sum of SO3TangentVector's
%
% Syntax
%   cumsum(v)   % sum along the first non singular dimension
%   cumsum(v,d) % sum along dimension d
%
% Input
%  v - @SO3TangentVector 
%
% Output
%  v - @SO3TangentVector

c = cumsum@vector3d(v,varargin{:});
c.rot = normalize(sum(v.rot,varargin{:}));
ensureCompatibleTangentSpaces(v,c,'equal');

end