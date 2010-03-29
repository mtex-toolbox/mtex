function Z = bingham2pdf(odf,h,r,varargin)


d = int32(get_option(varargin,{'prec','precision'},16,'double'));

h = vector3d(h);
r = vector3d(r);

if length(h) == 1  % pole figures
  Z = zeros(size(h));
elseif length(r) == 1 % inverse pole figures
  Z = zeros(size(r));
else
  error('Either h or r should be a single direction!');
end


kappa = reshape(odf.psi,[],1);

q1 = hr2quat(h,r);
q2 = q1 .* axis2quat(h,pi);
      
ASym = quaternion(symmetrise(odf.center));

sp = odf.c(1);

C = mhyper(odf.psi);

n = size(ASym,1);
progress(0,n);
for iA = 1:n
  
  progress(iA,n);
    
  A1 = dot_outer(q1,ASym(iA,:));
  A2 = dot_outer(q2,ASym(iA,:));
      
  a = (A1.^2 +  A2.^2) * kappa ./2;
  b = (A1.^2 -  A2.^2) * kappa ./2;
  c = (A1 .*  A2) * kappa;

  bc = sqrt(b.^2 + c.^2); 
  if isfinite(C)
    Zf = sp.* exp(a) ./ C .* besseli(0,bc)./ size(ASym,1);
  else  	
    Zf = sp.* call_extern('evalmhyper','INTERN',d,'EXTERN',kappa,a,bc)./ size(ASym,1);
  end
  
  Z = Z + Zf;
  
end
      