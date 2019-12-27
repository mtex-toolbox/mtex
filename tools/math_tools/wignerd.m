function dmm = wignerd(L,beta)

v = sqrt(cumsum(2*(L:-1:1)))/2;
v = [v fliplr(v)];
J = diag(v,1)+diag(-v,-1);

dmm = expm(beta*J);

[l,k] = meshgrid(-L:L,-L:L);
%dmm = dmm .* 1i.^abs(k) .* (-1i).^abs(l) .* (-1).^(k-l);
%dmm = dmm .* (-1).^(k-l);
dmm = dmm .* (-1).^(k.*(k<0)+l.*(l<0));


end

 