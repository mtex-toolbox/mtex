function g = grad(component,ori,varargin)
% gradient at orientation g
%
% Syntax
%   g = grad(component,ori)
%
% Input
%  component - @unimodalComponent
%  ori - @orientation
%
% Output
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DK(g1_i,g2_j) $$

if check_option(varargin,'check')
  g = grad@ODFComponent(component,ori,varargin{:});
  return
end

% we need to consider all symmetrically equivalent centers
q2 = quaternion(ori);
center = component.center(:);
qSS = quaternion(component.SS);
% forget about second symmetry
center.SS = specimenSymmetry;

psi = component.psi;
epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*4.5));

% initialize output
g = vector3d.zeros(size(ori));

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
  v = sparse(i,j,v,length(center),length(ori)) .* spfun(@psi.DK,d);
  
  % sum over all neighbours
  g = g - v.' * component.weights(:) ;
  
end
g = g ./ length(qSS) ./ numProper(component.CS) ;

% TODO: consider antipodal
if component.antipodal
  
end

