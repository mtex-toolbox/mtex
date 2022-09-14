function g = grad(SO3F,varargin)
% gradient at rotation rot
%
% Syntax
%   g = grad(SO3F,rot)
%
% Input
%  SO3F - @SO3FunRBF
%  rot  - @rotation
%
% Output
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DK(g1_i,g2_j) $$

if check_option(varargin,'check') || nargin == 1 || ~isa(varargin{1},'quaternion')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

rot = varargin{1}; varargin(1) = [];

% we need to consider all symmetrically equivalent centers
q2 = quaternion(rot);
center = SO3F.center(:);
qSS = unique(quaternion(SO3F.SS));
% forget about second symmetry
center.SS = specimenSymmetry;

psi = SO3F.psi;
epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*4.5));

% initialize output
g = vector3d.zeros(size(rot));

% comute the distance matrix and evaluate the kernel
for issq = 1:length(qSS)
  d = abs(dot_outer(qSS(issq) * center, q2,'epsilon',epsilon,...
    'nospecimensymmetry'));
  
  % make matrix sparse
  d(d<=cos(epsilon/2)) = 0;  
  [i,j] = find(d>cos(epsilon/2));
  
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
g = g ./ length(qSS) ./ length(SO3F.CS.properGroup) ;

% TODO: consider antipodal
if SO3F.antipodal
  warning('not yet implemented!!')
end

