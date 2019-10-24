n = 2;
n = 4;
n = 16;
I = HealpixGenerateSampling(n, 'rindex');
S = HealpixGenerateSampling(n, 'scoord');
C = SphToCart(S);
plot3(C(:,1),C(:,2),C(:,3), '.')
%plot3(C(:,1),C(:,2),C(:,3))
axis equal
