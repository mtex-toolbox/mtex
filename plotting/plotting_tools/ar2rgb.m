function rgb = ar2rgb(omega,radius,grayValue,varargin)
% compute rgb values from angle and radius
%
% Input
%  omega     -
%  radius    -
%  grayValue -
%
% Output
%  rgb       - 

L = (radius(:) - 0.5) .* grayValue(:) + 0.5;

S = grayValue(:) .* (1-abs(2*radius(:)-1)) ./ (1-abs(2*L-1));
S(isnan(S))=0;

[h,s,v] = hsl2hsv(omega(:),S(:),L(:));

% the following lines correct for small yellow and cyan range in normal hsv
% space
if ~check_option(varargin,'noHueCorrection')
  
  z = linspace(0,1,1000);

  r = 0;f = 0.5 + exp(- 200.*(mod(z-r+0.5,1)-0.5).^2);
  b = 0.6666;f = f + exp(- 200.*(mod(z-b+0.5,1)-0.5).^2);
  g = 0.3333;f = f + exp(- 200.*(mod(z-g+0.5,1)-0.5).^2);
  
  f = f./sum(f);
  f = cumsum(f);
  h = interp1(z,f,h);
end
  
rgb = reshape(hsv2rgb(h,s,v),[],3);

end

% some testing code for this correctiom
%
% h = linspace(0,1);
% s = ones(size(h));
% v = ones(size(h));
% rgb = reshape(hsv2rgb(h,s,v),1,[],3);
% imagesc(rgb), axis off
%
%
%
