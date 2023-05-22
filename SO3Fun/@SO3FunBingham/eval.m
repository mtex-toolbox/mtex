function f = eval(SO3F,rot,varargin)
% evaluate an odf at rotation rot

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3F,rot)
% end

ASym = symmetrise(SO3F.A);

f = zeros(size(rot));

for iA = 1:size(ASym,1)
  
  h = dot_outer(rot,ASym(iA,:),'noSymmetry').^2;
  h = h * SO3F.kappa;
  
  % fast way  1/1F1.*exp(h)
  fz = SO3F.weight * 1./SO3F.C0 .* exp(h);
    
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 

if isalmostreal(f)
  f = real(f);
end

end