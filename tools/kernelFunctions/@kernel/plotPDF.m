function plotPDF(psi,varargin)
% plot Radon transformed kernel

omega = linspace(-pi,pi,1000);
    
optionplot(omega/degree,psi.RK(cos(omega)),'LineWidth',2,varargin{:});
set(gcf,'Name',['Randon transformed kernel ',inputname(1)]);
xlim([min(omega/degree),max(omega/degree)]);

end
