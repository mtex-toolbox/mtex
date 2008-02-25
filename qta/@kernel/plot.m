function plot(kk,options,varargin)
% plot kernel function
%% Input
%  kk - @kernel
%% Options
%  K, RK, RADON, RRK, FOURIER, FOURIER_LOGLOG, EVEN, ODD, EVEN-ODD

colororder = ['b','g','r','c','m','k','y'];
charorder =  ['.','o','+','s','^','d','x'];

if nargin == 1, options = 'K';end

for i=1:length(kk)
		names(i,1:length(char(kk(i)))) = char(kk(i)); %#ok<AGROW>
end

for i = 1:length(kk)
  switch upper(options)
    case 'K'
			omega = linspace(-pi,pi,1000);
			plot(omega,kk(i).K(cos(omega/2)),'color',colororder(i),'LineWidth',2);
			set(gcf,'Name',['kernel ',inputname(1),' on SO(3)']);
			xlim([-pi,pi]);
		case {'RK','RADON'}
			omega = linspace(-pi,pi,1000);
			plot(omega,max(0,kk(i).RK(cos(omega))),'color',colororder(i),'LineWidth',2);
			set(gcf,'Name',['Randon transformed kernel ',inputname(1),' on S^2']);
			xlim([-pi,pi]);
		case 'RRK'
			p = linspace(-pi,pi,200);
			Z = max(0,kk(i).RRK(cos(p)',cos(p)));
			[X,Y] = meshgrid(p,p);
			surf(X,Y,Z);
			set(gcf,'Name',['RRK of kernel ',inputname(1)]);
			shading interp;
		case 'FOURIER'
			l = length(kk(1).A);
      for j = 2:length(kk)
        l = max(l,length(kk(j).A));
      end
      l = get_option(varargin,'bandwidth',l);
			A = zeros(1,l);
			A(1:min(l,length(kk(i).A))) = kk(i).A(1:min(l,length(kk(i).A)));
      if check_option(varargin,'logarithmic'), A = log(A)/log(10);end
			plot(A,charorder(i),'color',colororder(i),'MarkerSize',10)
      set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);
    case 'FOURIER_LOGLOG'
			l = length(kk(1).A);
      for j = 2:length(kk)
				l = max(l,length(kk(i).A));
      end
			A = zeros(1,l);
			A(1:length(kk(i).A)) = kk(i).A;
			loglog(abs(A),charorder(i),'color',colororder(i),'MarkerSize',10);
      set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);
		case 'EVEN'
			omega = linspace(-pi,pi,1000);
			plot(omega,GK(kk(i),cos(omega/2)),'color',colororder(i),'LineWidth',2);
      set(gcf,'Name',['Even part of the kernel ',inputname(1)]);
		case 'ODD'
			omega = linspace(-pi,pi,1000);
			plot(omega,UK(kk(i),cos(omega/2)),'color',colororder(i),'LineWidth',2);
      set(gcf,'Name',['Odd part of the kernel ',inputname(1)]);
		case 'EVEN_ODD'
			omega = linspace(-pi,pi,1000);
			plot(omega,GK(kk(i),cos(omega/2))-UK(kk(i),cos(omega/2)),'color',colororder(i));
      set(gcf,'Name',['Difference between even and odd part of the kernel ',inputname(1)]);
    otherwise
      error('unknown option');
  end
  hold on
end

if check_option(varargin,'Legend')
	legend(names,'Location','northeast');
end

hold off;
figure(gcf)
