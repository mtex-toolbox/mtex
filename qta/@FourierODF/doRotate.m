function odf = doRotate(odf,q,varargin)
% called by ODF/rotate
    
L = bandwidth(odf);
D = wignerD(q,'bandwidth',L);

for l = 0:L
  odf.f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
    reshape(odf.f_hat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
end
    
end
