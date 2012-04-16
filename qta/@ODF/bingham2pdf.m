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

% symmetrise h and r
hSym = symmetrise(h,odf.CS,varargin{:});
rSym = symmetrise(r,odf.SS);

C = mhyper(odf.psi);

for ih = 1:size(hSym,1)
  for ir = 1:size(rSym,1)
    
    q1 = hr2quat(hSym(ih,:),rSym(ir,:));
    q2 = q1 .* axis2quat(hSym(ih,:),pi);
    
    A1 = dot_outer(q1,quaternion(odf.center));
    A2 = dot_outer(q2,quaternion(odf.center));
    
    a = (A1.^2 +  A2.^2) * kappa ./2;
    b = (A1.^2 -  A2.^2) * kappa ./2;
    c = (A1 .*  A2) * kappa;

    bc = sqrt(b.^2 + c.^2);
    if isfinite(C)
      Zf = odf.c(1) * exp(a) ./ C .* besseli(0,bc);
    else
      Zf = odf.c(1) * call_extern('evalmhyper','INTERN',d,'EXTERN',kappa,a,bc);
    end
  
    Z = Z + Zf;
        
  end
end

Z = Z ./ size(hSym,1) ./ size(rSym,1);

end
