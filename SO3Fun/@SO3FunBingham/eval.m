function f = eval(SO3F,g,varargin)
% evaluate an odf at orientation g

ASym = quaternion(symmetrise(SO3F.A));

C = mhyper(SO3F.kappa);

g = quaternion(g);
f = zeros(size(g));

for iA = 1:size(ASym,1)
  
  h = dot_outer(g,ASym(iA,:)).^2;
  h = h * SO3F.kappa;
  
  % fast way  1/1F1.*exp(h)
  fz = 1./C .* exp(h);
    
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 
