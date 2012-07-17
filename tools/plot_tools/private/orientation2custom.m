function c = orientation2custom(o, varargin)



centers = get_option(varargin,'orientations',{idquaternion,[1 0 0]});

psi  = kernel('de la vallee','halfwidth',get_option(varargin,'halfwidth',10*degree));

s = size(o);
Color = ones([s,3]);
for k=1:2:numel(centers)
  
  center = centers{k};
  w = evalCos(psi,dot(o,center))./evalCos(psi,1);
  
  c = centers{k+1};  
    
  cdata = rgb2hsv(repmat(c,numel(o),1));
  cdata(:,2) = w.*cdata(:,2);
  cdata = reshape(hsv2rgb(cdata),[s,3]);
  
  Color = Color.*cdata;
end

c = Color;





