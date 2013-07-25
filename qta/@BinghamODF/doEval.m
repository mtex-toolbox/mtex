function f = doEval(odf,g,varargin)
% evaluate an odf at orientation g

% get precision
d = int32(get_option(varargin,{'prec','precision'},64,'double'));


ASym = quaternion(symmetrise(odf.A));

C = mhyper(odf.kappa);

g = quaternion(g);
f = zeros(size(g));

for iA = 1:size(ASym,1)
  
  h = dot_outer(g,ASym(iA,:)).^2;
  h = h * odf.kappa;
  
  if isfinite(C) % fast way  1/1F1.*exp(h)
    fz = 1./C.*exp(h);  
  else
    fz = call_extern('evalmhyper','INTERN',d,'EXTERN',odf.kappa,h); 
  end
  
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 
