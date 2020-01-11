function dmn = Wigner_D(L,rot)
% compute the Wigner d and Wigner D functions 
%
% Syntax
%
%   Dmn = Wigner_D(L,rot)
%   dmn = Wigner_D(L,beta)
%
% Input
%  L   - harmonic degree
%  rot - @rotation
%  beta - second Euler angle
%
% Output
%  Dmn - Wigner D matrix D_L^(m,n)
%  dmn - Wigner d matrix d_L^(m,n)
%


if isnumeric(rot)

  v = sqrt(cumsum(2*(L:-1:1)))/2;
  v = [v fliplr(v)];
  J = diag(v,1)+diag(-v,-1);

  dmn = expm(rot * J);

  [m,n] = meshgrid(-L:L,-L:L);
  %dmm = dmm .* 1i.^abs(k) .* (-1i).^abs(l) .* (-1).^(k-l);
  %dmm = dmm .* (-1).^(k-l);
  dmn = dmn .* (-1).^(n.*(n<0)+m.*(m<0));
  
else
  
  [alpha,beta,gamma] = Euler(rot,'ZYZ');
  
  [m,n] = meshgrid(-L:L,-L:L);
  v = sqrt(cumsum(2*(L:-1:1)))/2;
  v = [v fliplr(v)];
  J = diag(v,1)+diag(-v,-1);

  dmn = expm(beta * J);

  dmn = dmn .* (-1).^(n.*(n<0)+m.*(m<0));
  
  dmn = exp(-1i.*n.*gamma) .*  dmn .* exp(-1i.*m.*alpha);
  
end
  
end
