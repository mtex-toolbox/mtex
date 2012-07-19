function [c,options] = orientation2color(o,coloring,varargin)
% convert orientation to color
%
%% Input
%  o    - @orientation
%  coloring -
%    IPDF, HKL
%    BUNGE, BUNGE2, EULER, IHS
%    SIGMA, RODRIGUES
%    ANGLE


model = {...
  'bunge',...
  'angle',...
  'sigma',...
  'ihs',...
  'ipdf',...
  'rodrigues',...
  'rodriguesquat',...
  'rodriguesinverse',...
  'euler',...
  'bunge2',...
  'hkl',...
  'h',...
  'orientations'};

options = {};

if nargin == 0, c = model; return; end

switch lower(coloring)
  case model(1)
    c = euler2rgb(o,varargin{:});
  case model(2)
    c = angle(o(:))./degree;
    %     c = 1-repmat(( c-min(c) )./ (max(c)-min(c)),1,3);
  case model(3)
    c = sigma2rgb(o,varargin{:});
  case model(4)
    c = euler2rgb(o,varargin{:});
    c = rgb2hsv(c);
  case model([5 11 12]) % colorcoding according according to ipdf
    if isa(o,'orientation')
      [h,r] = quat2ipdf(o,varargin{:});
      options(1:2) = {'r',r};
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
      case model(12)
        c = ipdf2custom(vector3d(h),cs,options{:},varargin{:});
    end
  case model(6:8)
    switch coloring
      case model(6)
        o = project2FundamentalRegion(o);
      case model(8)
        o = inverse(project2FundamentalRegion(o));
    end
    h = Rodrigues(o);
    cs = get(o,'CS');
    c = ipdf2rgb(h,cs,varargin{:});
  case model(9)
    c = euler2rgb2(o,varargin{:});
  case model(10)
    c = euler2rgb3(o,varargin{:});
  case model(13)
    c = orientation2custom(o,varargin{:});    
  otherwise
    error('Unknown Colorcoding')
end

if 3*numel(o) == numel(c)
  c = reshape(c,[],3);
end
