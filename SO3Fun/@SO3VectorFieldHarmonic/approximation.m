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
% See also
% SO3FunHarmonic/approximation SO3VectorFieldHarmonic

if isa(values,'SO3TangentVector') && strcmp(values.tangentSpace,'right') 
  % make right sided tangent vectors to left sided
  values = ori.*values;
  varargin{end+1} = 'right';
end

% TODO: This method uses the very expensive approximation method

if isa(nodes,'orientation')
  nodes.SS = specimenSymmetry;
  SRight = nodes.CS;
  SLeft = nodes.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,specimenSymmetry);
end

SO3F = SO3FunHarmonic.approximation(nodes(:),values.xyz,varargin{:});

SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft);

if check_option(varargin,'right')
  SO3VF = right(SO3VF);
end

end
