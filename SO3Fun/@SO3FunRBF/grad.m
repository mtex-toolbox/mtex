function g = grad(SO3F,rot,varargin)
% gradient at rotation rot
%
% Syntax
%   g = grad(SO3F,rot)
%
% Input
%  SO3F - @SO3FunUnimodal
%  rot  - @rotation
%
% Output
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DK(g1_i,g2_j) $$

if check_option(varargin,'check')
  g = grad@SO3Fun(SO3F,rot,varargin{:});
  return
end

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
  v = sparse(i,j,v,length(center),length(rot)) .* spfun(@psi.DK,d);
  
  % sum over all neighbours
  g = g - v.' * SO3F.weights(:) ;
  
end
g = g ./ length(qSS) ./ length(SO3F.CS.properGroup) ;

% TODO: consider antipodal
if SO3F.antipodal
  
end

