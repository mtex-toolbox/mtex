function SO3VF = interpolate(nodes, values, varargin)
% Approximate a vector field on the rotation group (SO(3)) in its harmonic 
% representation from some given orientations with corresponding tangent 
% vectors and maybe some noise.
%
% We compute this vector field componentwise, i.e. we compute three
% SO3FunHarmonics individually by interpolation. So, see 
% <SO3FunHarmonic.interpolate.html |SO3FunHarmonic.interpolate|> for 
% further information.
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y)
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y,'bandwidth',48)
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y,'weights','equal')
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y,'bandwidth',48,'weights',W,'tol',1e-6,'maxit',200)
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y,'regularization',0) % no regularization
%   SO3VF = SO3VectorFieldHarmonic.interpolate(nodes,y,'regularization',1e-4,'SobolevIndex',2)
%
% Input
%  nodes - @rotation
%  y     - @vector3d
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% Options
%  bandwidth      - maximal harmonic degree (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  weights        - corresponding to the nodes (default: Voronoi weights, 'equal': all nodes are weighted similar, numeric array W: specific weights for every node)
%  tol            - tolerance as termination condition for lsqr
%  maxit          - maximum number of iterations as termination condition for lsqr
%  regularization - the energy functional of the lsqr solver is regularized by the Sobolev norm of SO3F with regularization parameter lambda (default: 1e-4)(0: no regularization)
%  SobolevIndex   - for regularization (default = 2)
%
% See also
% rotation/interp SO3FunHarmonic/interpolate 

if isa(nodes,'quadratureSO3Grid')
  SO3VF = SO3VectorFieldHarmonic.quadrature(nodes,values,varargin{:});
  return
end


if isa(values,'SO3TangentVector') 
  tS = values.tangentSpace;
else
  tS = SO3TangentSpace.extract(varargin);
  if sign(tS)>0
    warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
             'the left side tangent space. If you want them to be right sided ' ...
             'use SO3TangentVector(v,SO3TangentSpace.rightVector) instead.'])
  end
end

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% Do quadrature without specimenSymmetry and set SLeft afterwards
% (if left sided tangent space) clear crystalSymmetry otherwise
if tS.isRight
  nodes.CS = crystalSymmetry;
else
  nodes.SS = specimenSymmetry;
end

if isa(values,'vector3d')
  values = values.xyz;
end

if any(size(values) ~= [numel(nodes),3])
  error('The shape of the array of values does not match.')
end


SO3F = SO3FunHarmonic.interpolate(nodes(:),values.xyz,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
