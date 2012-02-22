function c = ipdf2custom(h,cs,varargin)
% converts orientations to rgb values


markers = get_option(varargin,{'markers','colorcenter'},{Miller(1,1,1),[1 0 0]});

r = get_option(varargin,'r',zvector);
s = size(h);

Color = ones(s(1),s(2),3);
for k=1:numel(markers)/2
  
  m = markers{k*2-1};
  c = markers{k*2};
  
  odf = fibreODF(m,zvector,cs,symmetry,...
    'halfwidth',get_option(varargin,{'radius','halfwidth'},10*degree));
  f = pdf(odf,h,zvector);  
  
  w = f./max(f);
  
  cdata = rgb2hsv(repmat(c,size(f)));
  cdata(:,2) = w.*cdata(:,2);
  cdata = reshape(hsv2rgb(cdata),[s,3]);
    
  Color = Color.*cdata;

end
c = Color;


