function S2F = radon(component,h,r,varargin)
% called by pdf 

% get precision
d = int32(get_option(varargin,{'prec','precision'},16,'double'));

h = vector3d(h);
r = vector3d(r);

S2F = zeros(size(h) .* size(r));

% symmetrise h and r
hSym = symmetrise(h,component.CS,varargin{:});
rSym = symmetrise(r,component.SS);

C = mhyper(component.kappa);

for ih = 1:size(hSym,1)
  for ir = 1:size(rSym,1)
    
    q1 = hr2quat(hSym(ih,:),rSym(ir,:));
    q2 = q1 .* axis2quat(hSym(ih,:),pi);
    
    A1 = dot_outer(q1,quaternion(component.A));
    A2 = dot_outer(q2,quaternion(component.A));
    
    a = (A1.^2 +  A2.^2) * component.kappa ./2;
    b = (A1.^2 -  A2.^2) * component.kappa ./2;
    c = (A1 .*  A2) * component.kappa;

    bc = sqrt(b.^2 + c.^2);
    S2F = S2F + reshape(exp(a) ./ C .* besseli(0,bc),size(S2F));
              
  end
end

S2F = S2F ./ size(hSym,1) ./ size(rSym,1);

end
