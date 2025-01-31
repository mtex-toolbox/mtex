function SO3F = interpolate(ori,values,varargin)
% compute an ODF by interpolating orientations and weights
%
% Syntax
%   odf = SO3Fun.interpolate(ori,values)
%   odf = SO3Fun.interpolate(ori,values,'harmonic')
%
% Input
%  ori - @orientation
%  values - double
%
% Output
%  SO3F - @SO3Fun
%
% Flags
%  ('harmonic'|'bingham'|'RBF') - approximation method (default: 'RBF')
%
% See also
% SO3FunRBF.approximate SO3FunHarmonic.approximate SO3FunBingham.approximate

if check_option(varargin,'bingham')
  SO3F = SO3FunBingham.approximate(ori,values,varargin);
  return
end
if check_option(varargin,'harmonic')
  SO3F = SO3FunHarmonic.approximate(ori,values,varargin);
  return
end

% default, because faster
SO3F = SO3FunRBF.approximate(ori,values,varargin);








