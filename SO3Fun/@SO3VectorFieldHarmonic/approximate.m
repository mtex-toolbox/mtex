function SO3VF = approximate(nodes, values, varargin)
% Approximate a vector field on the rotation group (SO(3)) in its harmonic 
% representation from a given vector field, or some given orientations with 
% corresponding tangent vectors w.r.t. some given noise.
%
% We compute this vector field componentwise, i.e. we compute three
% SO3FunHarmonics individually by approximation. So, see 
% <SO3FunHarmonic.approximate.html |SO3FunHarmonic.approximate|> for 
% further information.
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.approximate(odf)                 % exact computation by quadrature
%   SO3VF = SO3VectorFieldHarmonic.approximate(odf,'bandwidth',48)  % exact computation by quadrature
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y)
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y,'bandwidth',48)
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y,'weights','equal')
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y,'bandwidth',48,'weights',W,'tol',1e-6,'maxit',200)
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y,'regularization',0) % no regularization
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes,y,'regularization',1e-4,'SobolevIndex',2)
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes, values)
%   SO3VF = SO3VectorFieldHarmonic.approximate(nodes, values, 'bandwidth', bw)
%
% Input
%  odf   - @SO3VectorField
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
% SO3FunHarmonic/approximate SO3VectorFieldHarmonic


if isa(values,'SO3TangentVector') 
  tS = values.tangentSpace;
else
  tS = SO3TangentSpace.leftVector;
  warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
           'the left side tangent space. If you want them to be right sided ' ...
           'use SO3TangentVector(v,SO3TangentSpace.rightVector) instead.'])
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

SO3F = SO3FunHarmonic.approximate(nodes(:),values.xyz,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
