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
% Options
%  exact -
%  epsilon -
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DK(g1_i,g2_j) $$


% we need to consider all symmetrically equivalent centers
q2 = quaternion(ori);
CS = ori.CS;
center = component.center;
qSS = unique(quaternion(component.SS));
psi = component.psi;
epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*4));

% initialize output
g = vector3d.zeros(size(ori));

% comute the distance matrix and evaluate the kernel
for issq = 1:length(qSS)
  d = abs(dot_outer(center,qSS(issq) * q2,'epsilon',epsilon,...
    'nospecimensymmetry'));
   
  for iori = 1:length(ori)
    
    id = d(:,iori)>0;
    cc = project2FundamentalRegion(inv(qSS(issq) * q2(iori)) * quaternion(center,id),CS);
    v = log(cc);
    nv = norm(v);
    v(nv>0) = v(nv>0)./nv(nv>0);
    
    %c = project2FundamentalRegion(quaternion(center,id),CS,qSS(issq) * q2);
    %v = log(c,qSS(issq) * q2);
    g(iori) = g(iori) - sum(v .* component.weights(id) .* psi.DK(full(d(id,iori))));
  end
end

% TODO: consider antipodal
if component.antipodal
end

