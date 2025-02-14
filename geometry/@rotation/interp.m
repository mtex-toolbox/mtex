function SO3F = interp(ori,values,varargin)
% compute an ODF by approximating orientations at some function values
% (interpolating the orientations with weights)
% It is also possible to interpolate a vector field.
%
% For more information on the interpolation method and possible flags, see
% in the documention: 
% <SO3FunApproximationTheory.html Approximation of discrete data>.
%
% Syntax
%   SO3F = interp(ori,values)
%   SO3F = interp(ori,values,'halfwidth',1*degree,'resolution',7*degree,'tol',1e-3,'maxit',100,'density')
%   SO3F = interp(ori,values,'harmonic')
%   SO3F = interp(ori,values,'harmonic','bandwidth',48,'weights',W,'regularization',1e-4,'SobolevIndex',2,'tol',1e-6,'maxit',200)
%   SO3F = interp(ori,values,'bingham')
%
% Input
%  ori    - @orientation
%  values - double, @vector3d
%
% Output
%  SO3F - @SO3Fun, @SO3VectorFieldHarmonic
%
% Flags
%  ('harmonic'|'bingham'|'RBF') - interpolation method (default: 'RBF')
%
% See also
% SO3FunRBF.interpolate SO3FunHarmonic.interpolate
% SO3FunBingham.interpolate SO3VectorFieldHarmonic.interpolate

% Vector fields
if check_option(values,'vector3d')
  SO3F = SO3VectorFieldHarmonic.interpolate(ori,values,varargin{:});
  % TODO: componentwise SO3FunRBF.interpolate
  % TODO: Add SO3VectorFieldRBF
  return
end

if check_option(varargin,'bingham')
  SO3F = SO3FunBingham.interpolate(ori,values,varargin{:});
  return
end
if check_option(varargin,'harmonic')
  SO3F = SO3FunHarmonic.interpolate(ori,values,varargin{:});
  % SO3F = smooth(SO3F);
  return
end

% default, because faster
SO3F = SO3FunRBF.interpolate(ori,values,varargin{:});

% TODO: Maybe transform to SO3FunHarmonic at the end
% SO3F = SO3FunHarmonic(SO3F);

