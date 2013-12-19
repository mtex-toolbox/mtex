function f = eval_bingham(odf,g,varargin)
% evaluate odf using evalmhyper
%
%% Input
%  odf - @ODF
%  g   - @quaternion
% 
%% Output
%  f - double
%

d = int32(get_option(varargin,{'prec','precision'},64,'double'));
kappa = reshape(odf.psi,[],1);
ASym = quaternion(symmetrise(odf.center));


sc = odf.c(1);
C = mhyper(odf.psi);

g = quaternion(g);
f = zeros(size(g));

n = size(ASym,1);

%progress(0,n);
for iA = 1:n
  
  %progress(iA,n);
  
  h = dot_outer(g,ASym(iA,:)).^2;  
  h = h * kappa;
  
  if isfinite(C) % fast way  1/1F1.*exp(h)
    fz = sc./C.*exp(h);  
  else
    fz = sc.*call_extern('evalmhyper','INTERN',d,'EXTERN',kappa,h); 
  end
  
  f = f + reshape(fz, size(f))./ size(ASym,1);
  
end 


