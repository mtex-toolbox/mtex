function plotFourier(psi,varargin)
% plot the Chybeyshev coefficients of the kernel function
  
bw = get_option(varargin,'bandwidth',32);
bw = min(bw,length(psi.A)-1);
A = reshape(psi.A(1:bw+1),1,[]);

if check_option(varargin,'logarithmic')
  optiondraw(loglog(0:bw,abs(A)./(2*(0:bw)+1),...
    'marker','o','MarkerSize',5),varargin{:});
else
  optiondraw(semilogx(0:bw,A./(2*(0:bw)+1),...
    'marker','o','MarkerSize',5),varargin{:});
end
set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);

end
