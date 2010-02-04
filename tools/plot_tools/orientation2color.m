function c = orientation2color(o,coloring,varargin)
% convert orientation to color
%
%% Input
% o    - @orientation
% type - as string: BUNGE, ANGLE, SIGMA, IHS, IPDF
%

model = {'bunge','angle','sigma','ihs','ipdf',...
    'rodrigues','rodriguesquat','rodriguesinverse','euler','bunge2','hkl'};

if nargin == 0, c = model; return; end

switch coloring
  case model(1)
    c = euler2rgb(o,varargin{:});
  case model(2)
    c = angle(quaternion(o)).';
    c = 1-repmat(( c-min(c) )./ (max(c)-min(c)),1,3);
  case model(3)
    c = sigma2rgb(o,varargin{:});
  case model(4)
    c = euler2rgb(o,varargin{:});
    c = rgb2hsv(c);
  case model([5 11]) % colorcoding according according to ipdf
    if isa(o,'orientation')
      h = quat2ipdf(o,varargin{:});
      cs = get(o,'CS');
    else
      cs = get_option(varargin,'cs');
      h = o;
    end
    
    switch coloring
      case model(5)
        c = ipdf2rgb(vector3d(h),cs,varargin{:});
      case model(11)
        c = ipdf2hkl(vector3d(h),cs,varargin{:});
    end
  case model(6:8)
    switch coloring
      case model(6)
        q = getFundamentalRegion(o);
      case model(7)
        q = quaternion(o);
      case model(8)
        q = inverse(getFundamentalRegion(o));
    end
    h = quat2rodrigues(q);
    cs = get(o,'CS');
    c = ipdf2rgb(h,cs,varargin{:});
  case model(9)
    c = euler2rgb2(o,varargin{:});
  case model(10)
    c = euler2rgb3(o,varargin{:});
  otherwise
    error('Unknown Colorcoding')
end

c = reshape(c,[],3);
