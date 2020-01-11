function dmn = wigner_d(L,beta)
% Wigner d_k^mn function
% 
% 

v = sqrt(cumsum(2*(L:-1:1)))/2;
v = [v fliplr(v)];
J = diag(v,1)+diag(-v,-1);

dmn = expm(beta*J);

[m,n] = meshgrid(-L:L,-L:L);
%dmm = dmm .* 1i.^abs(k) .* (-1i).^abs(l) .* (-1).^(k-l);
%dmm = dmm .* (-1).^(k-l);
dmn = dmn .* (-1).^(n.*(n<0)+m.*(m<0));


end

 