function Z = doPDF(odf,h,r,varargin)
% called by pdf 

% get precision
d = int32(get_option(varargin,{'prec','precision'},16,'double'));

h = vector3d(h);
r = vector3d(r);

Z = zeros(size(h) .* size(r));

% symmetrise h and r
hSym = symmetrise(h,odf.CS,varargin{:});
rSym = symmetrise(r,odf.SS);

C = mhyper(odf.kappa);

for ih = 1:size(hSym,1)
  for ir = 1:size(rSym,1)
    
    q1 = hr2quat(hSym(ih,:),rSym(ir,:));
    q2 = q1 .* axis2quat(hSym(ih,:),pi);
    
    A1 = dot_outer(q1,quaternion(odf.A));
    A2 = dot_outer(q2,quaternion(odf.A));
    
    a = (A1.^2 +  A2.^2) * odf.kappa ./2;
    b = (A1.^2 -  A2.^2) * odf.kappa ./2;
    c = (A1 .*  A2) * odf.kappa;

    bc = sqrt(b.^2 + c.^2);
    if isfinite(C)
      Z = Z + reshape(exp(a) ./ C .* besseli(0,bc),size(Z));
    else
      Z = Z + reshape(call_extern('evalmhyper','INTERN',d,'EXTERN',odf.kappa,a,bc),size(Z));
    end
          
  end
end

Z = Z ./ size(hSym,1) ./ size(rSym,1);

end
