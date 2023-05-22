function value = grad(psi,varargin)
%
% docu!

N = psi.bandwidth;
A = psi.A(:);
[k,l]=meshgrid(1:N,1:N);
M = (mod(k+l+1,2) & k>=l);
A = (M * A(2:end)) .* (1:2:2*N-1)';
D = S2Kernel(A);

if check_option(varargin,'polynomial')
  innerGrad = @(t) 1;
else
  innerGrad = @(t) -sqrt(1-t.^2);
end

if nargin >= 2 && isnumeric(varargin{1})
  t = varargin{1};
  value = D.eval(t) .* innerGrad(t);
elseif check_option(varargin,'polynomial')
  value = D;
else
  value = S2KernelHandle(@(t) D.eval(t) .* innerGrad(t));
end

% TODO: Interpolation error: Try
% psi = S2DeLaValleePoussinKernel;
% psi2=S2Kernel(psi.A);
% omega = 35*degree:0.01:pi;
% plot(omega/degree,psi.grad(cos(omega)) )
% hold on
% plot(omega/degree, psi2.grad(cos(omega)) )
% hold off

end