function c = ipdf2custom(h,cs,varargin)
% converts orientations to rgb values


markers = get_option(varargin,{'h'},{Miller(1,1,1),[1 0 0]},'cell');

psi =  kernel('de la vallee','halfwidth',get_option(varargin,'halfwidth',10*degree));

h = Miller(vector3d(h(:)),cs);
m = Miller([markers{1:2:end}],cs);
dmatrix = reshape(dot_outer(h,m),[],numel(m));    

RK = get(psi,'RK');
val = bsxfun(@rdivide,RK(dmatrix),RK(ones(size(m))));
s = size(h);
Color = ones([s,3]);
for k=1:size(val,2)
  
  c = markers{2*k}; 
    
  cdata = rgb2hsv(repmat(c,numel(h),1));
  cdata(:,2) = val(:,k).*cdata(:,2);
  cdata = reshape(hsv2rgb(cdata),[s,3]);
  
  Color = Color.*cdata;
  
end

c = Color;


