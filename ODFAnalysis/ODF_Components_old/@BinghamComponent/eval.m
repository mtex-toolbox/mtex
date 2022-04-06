function f = eval(component,g,varargin)
% evaluate an odf at orientation g

ASym = quaternion(symmetrise(component.A));

C = mhyper(component.kappa);

g = quaternion(g);
f = zeros(size(g));

for iA = 1:size(ASym,1)
  
  h = dot_outer(g,ASym(iA,:)).^2;
  h = h * component.kappa;
  
  % fast way  1/1F1.*exp(h)
  fz = 1./C .* exp(h);
    
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 
