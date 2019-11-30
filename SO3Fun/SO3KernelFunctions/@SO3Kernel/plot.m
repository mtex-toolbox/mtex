function plot(psi,varargin)
% plot the kernel function      

omega = linspace(-pi,pi,1000);

if check_option(varargin,'DK')
  optionplot(omega/degree,psi.DK(cos(omega/2)),'LineWidth',2,varargin{:});
else
  optionplot(omega/degree,psi.K(cos(omega/2)),'LineWidth',2,varargin{:});
end
set(gcf,'Name',['kernel ',inputname(1),' on SO(3)']);
xlim([min(omega/degree),max(omega/degree)]);

end
    
