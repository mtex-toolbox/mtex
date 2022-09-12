function value = grad(psi,t)

N = psi.bandwidth;
A = psi.A(:);
[k,l]=meshgrid(1:N,1:N);
M = (mod(k+l+1,2) & k>=l);
A = (M * A(2:end)) .* (1:2:2*N-1)';
D = S2Kernel(A);

if nargin == 2
  value = - D.eval(t) .* sqrt(1-t.^2);
else
  value = S2KernelHandle(@(t) - D.eval(t) .* sqrt(1-t.^2));
end

% TODO: Interpolation error: Try
% psi = S2DeLaValleePoussin;
% psi2=S2Kernel(psi.A);
% omega = 35*degree:0.01:pi;
% plot(omega/degree,psi.grad(cos(omega)) )
% hold on
% plot(omega/degree, psi2.grad(cos(omega)) )
% hold off

end