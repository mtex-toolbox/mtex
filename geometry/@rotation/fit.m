function rot = fit(l,r,varargin)
% find rotation rot such that rot * l ~ r f
%
% Syntax
%
%   rot = rotation.fit(l,r)
%   rot = rotation.fit(l,r,'weights',w)
%
% Input
%  l, r - @vector3d
%
% Output
%  rot - @rotation
%
% Description
% Find the rotation that best maps all the vectors |l| onto the vectors |r|.
%
% See also
% rotation/rotation rotation/byMatrix rotation/byAxisAngle
% rotation/byEuler
%
% References
%
% * W. Kabsch, A solution for the best rotation to relate two sets of
% vectors, Acta Cryst. (1976). A32, 922.
%
% * B. K. P. Horn, Closed-form solution of absolute orientation using unit
% quaternions, Journal of the Optical Society of America A (1987), Vol, 4,
% 629.
%


w = get_option(varargin,'weights');
if ~isempty(w), l = l .* w; end

M = l * r;

switch lower(get_option(varargin,'method','kabsch'))
  
  case 'horn' % quaternion based method
    
    MS = M + M.';
    MA = M - M.';
    
    N = [trace(M) MA(2,3)             MA(3,1)              MA(1,2);
      MA(2,3)    M(1,1)-M(2,2)-M(3,3) MS(1,2)              MS(1,3);
      MA(3,1)    MS(1,2)              M(2,2)-M(1,1)-M(3,3) MS(2,3);
      MA(1,2)    MS(1,3)              MS(2,3)              M(3,3)-M(1,1)-M(2,2)];
    
    [V,lambda] = eig(N);
    [lambda,idx] = sort(diag(lambda));
    for i=1:1:length(idx)
      W(:,i)=V(:,idx(i));
    end
    V = W;

    % this is to cover the antipodal case -> TODO
    if length(l)== 3 && -min(lambda)>2*max(lambda)
      r(end) = -r(end);
      rot = rotation.fit(l,r);
    else
      rot = rotation(quaternion(V(:,4)));
    end
    
  case 'kabsch' % Kabsch algorithm
    
    [U,~,V] = svd(M);
    
    if length(l)<3
      S = ones(3);
      S(3,3) = det(V*U');
      rot = rotation.byMatrix(V*S*U');
    else
      rot = rotation.byMatrix(V*U');
      if l.antipodal || r.antipodal, rot.i = false; end
    end
end
end

function check

r = rotation.rand;
% u = [xvector;yvector;zvector];
u = vector3d.rand(randi(100,1));

v = (r * u).';

% add some noise
vn = v + 0.1 .* vector3d.rand(size(v));

% fit a rotation
%rec = rotation.fit(u,vn,'method','kabsch');
rec = rotation.fit(u,vn,'method','horn');

% the distance to the initial rotation
angle(r,rec)./degree

% the fit
f = sum(dot(rec * u,vn.'));

% check for local minimum
S3G = localOrientationGrid(specimenSymmetry,specimenSymmetry,1*degree,'resolution',0.5*degree);
all(f > sum(dot(rec * S3G * u,vn.'),2))

end
