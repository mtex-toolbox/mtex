function g = grad(SO3F,varargin)
% left-sided gradient of an SO3Fun
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3FunRBF
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorField
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DK(g1_i,g2_j) $$
%
% See also
% orientation/exp SO3FunHarmonic/grad SO3FunCBF/grad SO3VectorField


if check_option(varargin,'check') || nargin == 1 || ~isa(varargin{1},'quaternion')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

tS = SO3TangentSpace.extract(varargin{:});

rot = varargin{1}; varargin(1) = [];

if isempty(SO3F.center)
  g = vector3d.zeros(size(rot));
  return
end

% we need to consider all symmetrically equivalent centers
q2 = quaternion(rot);
center = SO3F.center;
qSS = unique(quaternion(SO3F.SS));
% forget about second symmetry (this destroys the grid structure)
% center = center(:);
center.SS = specimenSymmetry;

psi = SO3F.psi;
epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*4.5));

% initialize output
g = vector3d.zeros(size(rot));

% compute the distance matrix and evaluate the kernel
for issq = 1:length(qSS)

  d = abs(dot_outer( SO3F.center, inv(qSS(issq)) * q2,'epsilon',epsilon,...
    'nospecimensymmetry'));
  
  % make matrix sparse
  %   d(d<=cos(epsilon/2)) = 0;   % array size gets to big
  [i,j] = find(d>cos(epsilon/2));
  d = d(d>cos(epsilon/2));
    
  % the normalized logarithm
  v = log(reshape(qSS(issq) * center(i),[],1),reshape(q2(j),[],1),tS);
  v = v.normalize;
  
  % set up vector3d matrix - a tangential vector for any pair of
  % orientations
  v = sparse(i,j,v .* psi.grad(d),length(center),length(rot));
  
  % sum over all neighbours
  g = g - reshape(v.' * SO3F.weights(:),size(g));

end
g = g ./ length(qSS) ./ length(SO3F.CS.properGroup.rot) ;

g = SO3TangentVector(g,tS);

% TODO: consider antipodal
if SO3F.antipodal
  warning('not yet implemented!!')
end

