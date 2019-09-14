function C = inv(S)
% compliance to stiffness tensor
%
% Input
%  S - @complianceTensor
%
% Output
%  C - @stiffnessTensor
%

C = stiffnessTensor(inv@tensor(S));

end

% this can be done more explicitely by
function test

M = matrix(S,'voigt');

D = M(1,1,:) .* M(2,2,:) .* M(3,3,:) ...
  - M(1,1,:) .* M(2,3,:).^2 ...
  - M(2,2,:) .* M(1,3,:) .* M(1,3,:) ...
  - M(3,3,:) .* M(1,2,:).^2 ...
  + 2 * M(1,2,:) .* M(2,3,:) .* M(1,3,:);

C11 = (M(2,2,:) .* M(3,3,:)-M(2,3,:) .* M(2,3,:))/D;
C12 = (M(1,3,:) .* M(2,3,:)-M(1,2,:) .* M(3,3,:))/D;
C13 = (M(1,2,:) .* M(2,3,:)-M(1,3,:) .* M(2,2,:))/D;
C22 = (M(1,1,:) .* M(3,3,:)-M(1,3,:) .* M(1,3,:))/D;
C23 = (M(1,2,:) .* M(1,3,:)-M(2,3,:) .* M(1,1,:))/D;
C33 = (M(1,1,:) .* M(2,2,:)-M(1,2,:) .* M(1,2,:))/D;

% Enter tensor as 6 by 6 matrix,M line by line.
M = [[  C11   C12   C13    0     0     0];...
    [   C12   C22   C23    0     0     0];...
    [   C13   C23   C33    0     0     0];...
    [   0      0      0   1./M(4,4,:)    0     0];...
    [   0      0      0    0    1./M(5,5,:)    0];...
    [   0      0      0    0     0   1./M(6,6,:)]];
% 
C = reshape(stiffnessTensor(M,cs_tensor,'density',rho),size(S));

end