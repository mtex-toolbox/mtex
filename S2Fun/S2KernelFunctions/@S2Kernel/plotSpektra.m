function plotSpektra(psi,varargin)
% plot the Legendre coefficients of the kernel function
  
bw = get_option(varargin,'bandwidth',32);
n = 0:bw;
A = zeros(1,bw+1);

bw = min(bw,length(psi.A)-1);

A(1:bw+1) = psi.A(1:bw+1);
A = A./ (2*n+1);

if check_option(varargin,'logarithmic')
  optiondraw(loglog(n, abs(A), 'marker','o','MarkerSize',5),varargin{:});
else
  optiondraw(semilogx(n, A, 'marker','o','MarkerSize',5),varargin{:});
end
set(gcf,'Name',['Legendre coefficients of the kernel ',inputname(1)]);

end