function SO3F = interp(ori,values,varargin)
% compute an ODF by approximating orientations at some function values
% (interpolating the orientations with weights)
% Maybe we compute a vector field.
%
% Syntax
%   SO3F = interp(ori,values)
%   SO3F = interp(ori,values,'harmonic')
%
% Input
%  ori    - @orientation
%  values - double, @vector3d
%
% Output
%  SO3F - @SO3Fun, @SO3VectorFieldHarmonic
%
% Flags
%  ('harmonic'|'bingham'|'RBF') - approximation method (default: 'RBF')
%
% See also
% SO3FunRBF.approximate SO3FunHarmonic.approximate
% SO3FunBingham.approximate SO3VectorFieldHarmonic.approximate

% Vector fields
if check_option(values,'vector3d')
  SO3F = SO3VectorFieldHarmonic.approximate(ori,values,varargin{:});
  % TODO: componentwise SO3FunRBF.approximate
  % TODO: Add SO3VectorFieldRBF
  return
end

if check_option(varargin,'bingham')
  SO3F = SO3FunBingham.approximate(ori,values,varargin{:});
  return
end
if check_option(varargin,'harmonic')
  SO3F = SO3FunHarmonic.approximate(ori,values,varargin{:});
  % SO3F = smooth(SO3F);
  return
end

% default, because faster
SO3F = SO3FunRBF.approximate(ori,values,varargin{:});

% TODO: Maybe transform to SO3FunHarmonic at the end
% SO3F = SO3FunHarmonic(SO3F);







