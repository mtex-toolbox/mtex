function component = rotate(component,q,varargin)
% called by ODF/rotate
    
L = component.bandwidth;
D = WignerD(q,'bandwidth',L);

for l = 0:L
  component.f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    reshape(component.f_hat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
    reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1).' ;
end
    
end
