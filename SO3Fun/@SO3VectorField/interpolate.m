function SO3VF = interpolate(ori,values,varargin)
% compute a vector field by interpolating orientations and weights
%
% Syntax
%   SO3VF = SO3VectorField.interpolate(ori,values)
%
% Input
%  ori    - @orientation
%  values - @vector3d
% 
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% See also
% SO3VectorFieldHarmonic.approximate SO3FunHarmonic.approximate 

SO3VF = SO3VectorFieldHarmonic.approximate(ori,values,varargin{:});

% TODO: componentwise SO3FunRBF.approximate
% TODO: Add SO3VectorFieldRBF