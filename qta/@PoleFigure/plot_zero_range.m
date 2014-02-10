function plot_zero_range(pf,varargin)
% implements the zero range method
%
% Input
%  pf  - @PoleFigure

% plotting grid
S2G = plotS2Grid('antipodal',varargin{:});

% loop over pole figures
for ip = 1:pf.numPF

  fprintf('applying zero range method to %s \n',char(pf.allH{ip}));

  zr{ip} = double(calcZeroRange(pf.select(ip),S2G,varargin{:})); %#ok<AGROW>
  
end

multiplot(@(i) S2G,@(i) zr{i},length(zr),...
  'DISP',@(i,Z) [' plot PDF h=',char(pf.allH{i})],...
  'ANOTATION',@(i) pf.allH{i},...
  'smooth','interp',varargin{:});

