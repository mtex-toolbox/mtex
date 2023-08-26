function SO3TV = left(SO3TV,rot,varargin)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3TV = left(SO3TV,rot)
%
% Input
%  SO3TV - @SO3TangentVector
%  rot - @rotation of the corresponding tangent space
%
% Output
%  SO3TV - @SO3TangentVector (left-sided tangent vectors)
%
% See also
% SO3TangentVector/SO3TangentVector SO3TangentVector/right

if strcmp(SO3TV.tangentSpace,'left'), return; end

SO3TV = SO3TangentVector( rot.*SO3TV , 'left');

end