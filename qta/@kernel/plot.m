function plot(kk,options,varargin)
% plot kernel function
%% Input
%  kk - @kernel
%% Options
%  symmetric - plot from -pi to pi
%  K, RK, RADON, RRK, FOURIER, FOURIER_LOGLOG, EVEN, ODD, EVEN-ODD

%charorder =  ['*','o','+','s','^','d','x'];

if nargin == 1, options = 'K';end

for i=1:length(kk)
		names(i,1:length(char(kk(i)))) = char(kk(i)); %#ok<AGROW>
end

if check_option(varargin,'symmetric')
  omega(1) = -pi;
  omega(2) = pi;
else
  omega(1) = 0;
  omega(2) = pi;
end
omega = linspace(min(omega),max(omega),1000);

for i = 1:length(kk)
  switch upper(options)
    case 'K'			
			optionplot(omega/degree,kk(i).K(cos(omega/2)),'LineWidth',2,varargin{:});
			set(gcf,'Name',['kernel ',inputname(1),' on SO(3)']);
			xlim([min(omega/degree),max(omega/degree)]);
		case {'RK','RADON'}
      optionplot(omega/degree,kk(i).RK(cos(omega)),'LineWidth',2,varargin{:});
			set(gcf,'Name',['Randon transformed kernel ',inputname(1),' on S^2']);
      xlim([min(omega/degree),max(omega/degree)]);
    case 'RRK'
			p = linspace(min(omega),max(omega),200);
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
      optiondraw(semilogx(0:length(A)-1,A./(2*(0:length(A)-1)+1),...
        'marker','o','MarkerSize',5),varargin{:});
      %'marker',charorder(i)
      xlim([0,l]);
      set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);
    case 'FOURIER_LOGLOG'
			l = length(kk(1).A);
      for j = 2:length(kk)
				l = max(l,length(kk(i).A));
      end
			A = zeros(1,l);
			A(1:length(kk(i).A)) = kk(i).A;
			loglog(abs(A./(2*(0:length(A)-1)+1)),charorder(i),'MarkerSize',10);
      set(gcf,'Name',['Fourier coefficients of the kernel ',inputname(1)]);
		case 'EVEN'
			optionplot(omega,GK(kk(i),cos(omega/2)),'LineWidth',2,varargin{:});
      set(gcf,'Name',['Even part of the kernel ',inputname(1)]);
		case 'ODD'
			optionplot(omega,UK(kk(i),cos(omega/2)),'LineWidth',2,varargin{:});
      set(gcf,'Name',['Odd part of the kernel ',inputname(1)]);
		case 'EVEN_ODD'
			optionplot(omega,GK(kk(i),cos(omega/2))-UK(kk(i),cos(omega/2)),varargin{:});
      set(gcf,'Name',['Difference between even and odd part of the kernel ',inputname(1)]);
    otherwise
      error('unknown option');
  end
  hold all
end

if check_option(varargin,'Legend')
	legend(names,'Location','northeast');
end

hold off;
figure(gcf)
