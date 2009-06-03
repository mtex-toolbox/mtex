function d = orientation2color(grid,coloring,varargin)
% convert SO3Grid to color
%
%% Input
% grid   - @SO3Grid
% type   - as string: BUNGE, ANGLE, SIGMA, IHS, IPDF
%

model = {'bunge','angle','sigma','ihs','ipdf',...
    'rodrigues','rodriguesquat','rodriguesinverse'};

if nargin == 0
  d = model;
  return;
elseif isa(grid,'SO3Grid')
  cs = get(grid,'CS');
  ss = get(grid,'SS');
else
  cs = varargin{1};
  d = ipdf2rgb(grid,cs,varargin{2:end});
  return
end

switch coloring
  case model(1)
    d = euler2rgb(grid,varargin{:});
  case model(2)
    d = quat2rgb(grid,cs,varargin{:});
  case model(3)
    d = sigma2rgb(grid,varargin{:});
  case model(4)
    d = euler2rgb(grid,cs,ss,varargin{:});
    d = rgb2hsv(d);
  case model(5) % colorcoding according according to ipdf    
    h = quat2ipdf(grid,varargin{:});
    d = ipdf2rgb(h,cs,varargin{:});
  case model(6:8)
    switch coloring
      case model(6)  
        q = getFundamentalRegion(grid);
      case model(7)
        q = quaternion(grid);
      case model(8)
        q = inverse(getFundamentalRegion(grid));
    end
    h = quat2rodrigues(q);
    d = ipdf2rgb(h,cs,varargin{:});
end
