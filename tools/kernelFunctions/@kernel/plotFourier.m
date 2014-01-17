function plotFourier(psi,varargin)
% plot the Chybeyshev coefficients of the kernel function
      
if check_option(varargin,'logarithmic')
  optiondraw(loglog(0:length(psi.A)-1,abs(psi.A)./(2*(0:length(psi.A)-1)+1),...
    'marker','o','MarkerSize',5),varargin{:});
else
  optiondraw(semilogx(0:length(psi.A)-1,psi.A./(2*(0:length(psi.A)-1)+1),...
    'marker','o','MarkerSize',5),varargin{:});
end
set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);

end
