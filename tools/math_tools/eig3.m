function [lambda,v] = eig3(A)
% returns the largest eigenvalue of a symmetric 3x3 matrix
%

% Given a real symmetric 3x3 matrix A, compute the eigenvalues
p1 = A(1,2)^2 + A(1,3)^2 + A(2,3)^2;

% A is diagonal.
if p1 == 0, lambda = max(diag(A(1,1))); return; end

q = (A(1,1) + A(2,2) + A(3,3))/3;
p2 = (A(1,1) - q)^2 + (A(2,2) - q)^2 + (A(3,3) - q)^2 + 2 * p1;
p = sqrt(p2 / 6);

%r = det(A-q*Id) / 2 / p^3;
r = (A(1,1)-q) *( (A(2,2)-q) * (A(3,3)-q) - A(3,2)^2) + A(2,1) * (A(3,1) * A(3,2)...
  - A(2,1) * (A(3,3)-q)) + A(3,1) * (A(2,1) * A(3,2) - (A(2,2)-q) * A(3,1));
r = r / 2 / p^3;

% In exact arithmetic for a symmetric matrix  -1 <= r <= 1
% but computation error can leave it slightly outside this range.
if (r <= -1)
  phi = pi / 3;
elseif (r >= 1)
  phi = 0;
else
  phi = acos(r) / 3;
end

% the eigenvalues satisfy eig3 <= eig2 <= eig1
%lambda = zeros(3,1);
lambda = q + 2 * p * cos(phi);
%lambda(3) = q + 2 * p * cos(phi + (2*pi/3));
%lambda(2) = 3 * q - lambda(1) - lambda(2);     % since trace(A) = eig1 + eig2 + eig3


if nargout > 1
  
  %v = cross(A(:,1),A(:,2));
  v = [0;0;0];
  v(1) = A(2,1) * A(3,2) - A(3,1) * (A(2,2) - lambda);
  v(2) = A(3,1) * A(1,2) - (A(1,1) - lambda) * A(3,2);
  v(3) = (A(1,1) - lambda) * (A(2,2) - lambda) - A(2,1) * A(1,2);
  
  v = v ./sqrt(v(1).^2 + v(2).^2 + v(3).^2);
  
end

end

