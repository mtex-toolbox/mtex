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
%  nodes - @rotation, @orientation
%  y - @vector3d, @spinTensor, @SO3TangentVector
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


% extract data (rot, val, tS)
if isa(nodes,'SO3TangentVector')
  
  if nargin>1
    varargin = {values,varargin{:}};
  end
  
  tS = SO3TangentSpace.extract(varargin{:},nodes.tangentSpace);
  % Maybe change tangent space
  nodes = transformTangentSpace(nodes,tS);
  
  rot = nodes.rot;
  val = vector3d(nodes);
  varargin = {nodes.hiddenCS, nodes.hiddenSS, varargin{:}};

elseif isa(nodes,'rotation') && isa(values,'SO3TangentVector')
  
  tS = SO3TangentSpace.extract(varargin{:},values.tangentSpace);
  % Maybe change tangent space
  values = transformTangentSpace(values,tS);
  
  % check for same rotations & same symmetries
  r = values.rot;
  if isa(nodes,'orientation')
    r.CS = nodes.CS; r.SS = nodes.SS;
  end
  if any(r(:) ~= nodes(:))
    error('The input nodes have to be the same as the rotations which define the tangent spaces of the tangent vectors.')
  end
  
  rot = values.rot;
  val = vector3d(values);
  varargin = { values.hiddenCS , values.hiddenSS , varargin{:} };

elseif isa(nodes,'rotation') && ( isa(values,'vector3d') || isa(values,'spinTensor'))

  rot = nodes;
  tS = SO3TangentSpace.extract(varargin{:});
  val = vector3d(values);
  % It will be ensured later, that one of the symmetries of the input 
  % orientation has id=1 (dependent on the tangent space representation) 

end


% Check input values
if isnumeric(val)
  error('The input values have to be of class vector3d.')
end
if numel(val) ~= numel(rot)
  error('The numbers of nodes and values do not match.')
end


% extract symmetries
[SRight,SLeft] = extractSym(varargin);
if isa(rot,'orientation')
  if SRight.id==1
    SRight = rot.CS;
  end
  if SLeft.id==1
    SLeft = rot.SS;
  end
else
  rot = orientation(rot,SRight,SLeft);
end


% For interpolation, one of the symmetries needs to have id=1.
% This depends on the tangent space representation 
if tS.isRight
  rot.CS = crystalSymmetry;
else
  rot.SS = specimenSymmetry;
end


% do interpolation
SO3F = SO3FunHarmonic.interpolate(rot(:),val.xyz,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
