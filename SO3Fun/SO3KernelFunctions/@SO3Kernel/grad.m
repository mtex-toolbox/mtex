function value = grad(psi,co2)


N = psi.bandwidth;
A = psi.A(:);

k = 1:0.5:(N+1)/2;
k(2:2:end) = 0;
l = (N+1)/2:0.5:N;
l(end-1:-2:1)=0;
M = triu(hankel(k,l)-toeplitz([0,k(1:end-1)]));

Ahat = (-4) * (M*A(2:end));

Dpsi = SO3Kernel(Ahat);

% TODO: Interpolation error: Try
% psi = SO3DeLaValleePoussinKernel(90);
% psi2=SO3Kernel(psi.A);
% omega = 35*degree:0.01:pi;
% plot(omega/degree,psi.grad(cos(omega/2)) )
% hold on
% plot(omega/degree, psi2.grad(cos(omega/2)) )
% hold off


if nargin == 2
  value = Dpsi.eval(co2).*co2.*sqrt(1-co2.^2);
else
  value = SO3KernelHandle(@(co2) Dpsi.eval(co2).*co2.*sqrt(1-co2.^2));
end