function [rgb,options] = om_ipdfCenter(o,varargin)
% converts orientations to rgb values
% description missing

% convert to Miller
if isa(o,'orientation')
  h = quat2ipdf(o,varargin{:});
  cs = o.CS;
else
  h = o;
  cs = varargin{1};
end

%
markers = get_option(varargin,{'ipdfCenter'},{Miller(1,1,1),[1 0 0]},'cell');

psi =  deLaValeePoussinKernel('halfwidth',get_option(varargin,'halfwidth',10*degree));

h = Miller(vector3d(h(:)),cs);
m = Miller([markers{1:2:end}],cs);
dmatrix = reshape(dot_outer(h,m),[],length(m));    

val = bsxfun(@rdivide,psi.RK(dmatrix),psi.RK(ones(size(m))));
s = size(h);
rgb = ones([s,3]);

for k=1:size(val,2)
  
  c = markers{2*k}; 
    
  cdata = rgb2hsv(repmat(c,length(h),1));
  cdata(:,2) = val(:,k).*cdata(:,2);
  cdata = reshape(hsv2rgb(cdata),[s,3]);
  
  rgb = rgb.*cdata;
  
end

options = varargin;
