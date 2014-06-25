function v = planeIntersect(N1,N2,alpha1,alpha2)
% compute the intersection of two planes

d = dot(N1,N2);
c1 = (alpha1 - alpha2 .* d)./(1-d.^2);
c2 = (alpha2 - alpha1 .* d)./(1-d.^2);

% the line intersecting both planes is
% a + lambda b
a = c1 .* N1 + c2 .* N2;
b = cross(N1,N2);

% determine lambda such that norm(a + lambda b) = 1
p = dot(a,b) ./ norm(b).^2;
q = (norm(a).^2 - 1)./norm(b).^2;

lambda1 = - p + sqrt(p.^2 - q);
lambda2 = - p - sqrt(p.^2 - q);

% compute the points on the sphere
v = [a(:) + lambda1(:) .* b(:), a(:) + lambda2(:) .* b(:)];

end
