function c = orientation2color(grid,coloring,varargin)
% convert SO3Grid to color
%
%% Input
% grid   - @SO3Grid
% type   - as string: BUNGE, ANGLE, SIGMA, IHS, IPDF
%

model = {'bunge','angle','sigma','ihs','ipdf',...
    'rodrigues','rodriguesquat','rodriguesinverse'};

if nargin == 0, c = model; return; end

gl = GridLength(grid);
gl = cumsum([0 gl]);
c = zeros(gl(end),3);

for i = 1:length(grid)
  
  switch coloring
    case model(1)
      d = euler2rgb(grid(i),varargin{:});
    case model(2)
      d = rotangle(quaternion(grid(i))).';
      d = 1-repmat(d ./ max(d),1,3);
    case model(3)
      d = sigma2rgb(grid(i),varargin{:});
    case model(4)
      d = euler2rgb(grid(i),varargin{:});
      d = rgb2hsv(d);
    case model(5) % colorcoding according according to ipdf
      if isa(grid,'SO3Grid')
        h = quat2ipdf(grid(i),varargin{:});
        cs = get(grid(i),'CS');
      else
        cs = get_option(varargin,'cs');
        h = grid;
      end
      d = ipdf2rgb(vector3d(h),cs,varargin{:});
    case model(6:8)
      switch coloring
        case model(6)
          q = getFundamentalRegion(grid(i));
        case model(7)
          q = quaternion(grid(i));
        case model(8)
          q = inverse(getFundamentalRegion(grid(i)));
      end
      h = quat2rodrigues(q);
      d = ipdf2rgb(h,cs,varargin{:});
  end
  c(1+gl(i):gl(i+1),:) = d;
end

