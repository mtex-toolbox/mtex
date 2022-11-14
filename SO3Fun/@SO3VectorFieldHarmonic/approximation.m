function SO3VF = approximation(nodes, values, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.approximation(nodes, values)
%   SO3VF = SO3VectorFieldHarmonic.approximation(nodes, values, 'bandwidth', bw)
%
% Input
%   nodes - @rotation
%   values - @vector3d
%
% Output
%   SO3VF - @SO3VectorFieldHarmonic
%
% Options
%   bandwidth - maximal degree of the Wigner-D functions (default: 128)
%

% TODO: This method uses the very expensive approximation method

SO3F = SO3FunHarmonic.approximation(nodes(:),values.xyz,varargin{:});

SO3VF = SO3VectorFieldHarmonic(SO3F);

end
