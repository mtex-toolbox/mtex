function g = grad(SO3F,varargin)
% right-sided gradient of an SO3Fun
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


if check_option(varargin,'check') || nargin == 1 || ~isa(varargin{1},'quaternion')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

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
% center.SS = specimenSymmetry;

psi = SO3F.psi;
epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*4.5));

% initialize output
g = vector3d.zeros(size(rot));

% comute the distance matrix and evaluate the kernel
for issq = 1:length(qSS)
  d = abs(dot_outer( center, inv(qSS(issq)) * q2,'epsilon',epsilon,...
    'nospecimensymmetry'));
  
  % make matrix sparse
%   d(d<=cos(epsilon/2)) = 0;   % array size gets to big
  [i,j] = find(d>cos(epsilon/2));
  I = find(d>cos(epsilon/2));
  V = d(I);
  d = sparse(i,j,V,size(d,1),size(d,2));

  
  % the normalized logarithm
  v = log(reshape(qSS(issq) * center(i),[],1),reshape(q2(j),[],1),varargin{:});
  nv = norm(v);
  v(nv>0) = v(nv>0) ./ nv(nv>0);
  
  % set up vector3d matrix - a tangential vector for any pair of
  % orientations
  v = sparse(i,j,v,length(center),length(rot)) .* spfun(@psi.grad,d);
  
  % sum over all neighbours
  g = g - reshape(v.' * SO3F.weights(:),size(g)) ;
  
end
g = g ./ length(qSS) ./ length(SO3F.CS.properGroup.rot) ;

% TODO: consider antipodal
if SO3F.antipodal
  warning('not yet implemented!!')
end

