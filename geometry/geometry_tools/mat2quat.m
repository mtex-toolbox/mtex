function q = mat2quat(mat,varargin)
% converts direction cosine matrix to quaternion
%
% Syntax
%   q = mat2quat(mat)
%
% Input
%  mat - vector of matrixes
%
% Output
%  q - @quaternion
%
% See also
%
% quaternion_matrix Euler axis2quat hr2quat
%
% Description
% Wertz says to the algo similar to this with largest divisor
%       q4 = 1/2*sqrt((1+mat(1,1)+mat(2,2)+mat(3,3))); 
% Eqn 12-14a - c
%  Quat(1) = (mat(2,3)-mat(3,2))/q4/4;
%  Quat(2) = (mat(3,1)-mat(1,3))/q4/4;
%  Quat(3) = (mat(1,2)-mat(2,1))/q4/4;
%  Quat(4) = q4

Quat=zeros(4,1);
 
%Compute absolute values of the four quaternions from diags of Eqn 12-13
%absQ=0.5*sqrt([1 -1 -1;-1 1 -1;-1 -1 1;1 1 1]*diag(mat)+1);

absQ(1,:) = 0.5 * sqrt(1+mat(1,1,:)+mat(2,2,:)+mat(3,3,:));
absQ(2,:) = 0.5 * sqrt(1-mat(1,1,:)-mat(2,2,:)+mat(3,3,:));
absQ(3,:) = 0.5 * sqrt(1+mat(1,1,:)-mat(2,2,:)-mat(3,3,:));
absQ(4,:) = 0.5 * sqrt(1-mat(1,1,:)+mat(2,2,:)-mat(3,3,:));

[~,ind]=max(absQ); % Select biggest for best accuracy

qind = ind == 1;
if any(qind)
  Quat(1,qind)=absQ(1,qind);
  Quat(2,qind)=squeeze((mat(2,3,qind)-mat(3,2,qind))).'.*0.25./absQ(1,qind);
  Quat(3,qind)=squeeze((mat(3,1,qind)-mat(1,3,qind))).'.*0.25./absQ(1,qind);
  Quat(4,qind)=squeeze((mat(1,2,qind)-mat(2,1,qind))).'.*0.25./absQ(1,qind);
end

qind = ind == 2;
if any(qind)
  Quat(1,qind)=squeeze(mat(1,2,qind)-mat(2,1,qind)).'.*0.25./absQ(2,qind);
  Quat(2,qind)=squeeze(mat(3,1,qind)+mat(1,3,qind)).'.*0.25./absQ(2,qind);
  Quat(3,qind)=squeeze(mat(3,2,qind)+mat(2,3,qind)).'.*0.25./absQ(2,qind);
  Quat(4,qind)=absQ(2,qind);
end

qind = ind == 3;
if any(qind)
  Quat(1,qind)=squeeze(mat(2,3,qind)-mat(3,2,qind)).'.*0.25./absQ(3,qind);
  Quat(2,qind)=absQ(3,qind);
  Quat(3,qind)=squeeze(mat(1,2,qind)+mat(2,1,qind)).'.*0.25./absQ(3,qind);
  Quat(4,qind)=squeeze(mat(3,1,qind)+mat(1,3,qind)).'.*0.25./absQ(3,qind);
end
    
qind = ind == 4;
if any(qind)
  Quat(1,qind)=squeeze(mat(3,1,qind)-mat(1,3,qind)).'.*0.25./absQ(4,qind);
  Quat(2,qind)=squeeze(mat(1,2,qind)+mat(2,1,qind)).'.*0.25./absQ(4,qind);
  Quat(3,qind)=absQ(4,qind);
  Quat(4,qind)=squeeze(mat(2,3,qind)+mat(3,2,qind)).'.*0.25./absQ(4,qind);
end

q = quaternion(real(Quat));
q = q./norm(q);
q = q';
