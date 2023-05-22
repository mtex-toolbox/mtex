function plot(psi,varargin)
% plot the kernel function      

omega = linspace(-pi,pi,1000);

optionplot(omega/degree,psi.eval(cos(omega/2)),'LineWidth',2,varargin{:});

set(gcf,'Name',['kernel ',inputname(1),' on SO(3)']);
xlim([min(omega/degree),max(omega/degree)]);

end