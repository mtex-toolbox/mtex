function plot_zero_range(pf,varargin)
% implements the zero range method
%
% Input
%  pf  - @PoleFigure

% plotting grid
S2G = plotS2Grid('antipodal',varargin{:});

% loop over pole figures
for ip = 1:length(pf)

  fprintf('applying zero range method to %s \n',char(get(pf(ip),'Miller')));

  zr{ip} = double(calcZeroRange(pf(ip),S2G,varargin{:})); %#ok<AGROW>
  
end

multiplot(@(i) S2G,@(i) zr{i},length(zr),...
  'DISP',@(i,Z) [' plot PDF h=',char(get(pf(i),'Miller'))],...
  'ANOTATION',@(i) get(pf(i),'Miller'),...
  'smooth','interp',varargin{:});

