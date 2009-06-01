function d = orientation2color(grid,coloring,varargin)
% convert SO3Grid to color
%
%% Input
% grid   - @SO3Grid
% type   - as string: BUNGE, ANGLE, SIGMA, IHS, IPDF
%

if isa(grid,'SO3Grid')
  cs = get(grid,'CS');
  ss = get(grid,'SS');
else
  cs = varargin{1};
  d = ipdf2rgb(grid,cs,varargin{2:end});
  return
end

switch coloring
  case 'bunge'
    d = euler2rgb(grid,varargin{:});
  case 'angle'
    d = quat2rgb(grid,cs,varargin{:});
  case 'sigma'
    d = sigma2rgb(grid,varargin{:});
  case 'ihs'
    d = euler2rgb(grid,cs,ss,varargin{:});
    d = rgb2hsv(d);
  case 'ipdf'     % colorcoding according according to ipdf    
    h = quat2ipdf(grid,varargin{:});
    d = ipdf2rgb(h,cs,varargin{:});
end