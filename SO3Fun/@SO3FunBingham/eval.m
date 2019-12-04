function f = eval(SO3F,rot,varargin)
% evaluate an odf at rotation rot

ASym = symmetrise(SO3F.A);

f = zeros(size(rot));

for iA = 1:size(ASym,1)
  
  h = dot_outer(rot,ASym(iA,:),'noSymmetry').^2;
  h = h * SO3F.kappa;
  
  % fast way  1/1F1.*exp(h)
  fz = 1./SO3F.C0 .* exp(h);
    
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 
