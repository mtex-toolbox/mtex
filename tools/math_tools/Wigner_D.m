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

% %% Construction of Wigner-d functions
% n=2;
% beta = rand;
% 
% D=zeros(2*n+1);
% for k=-n:n
%   for l=-n:n
%     a=abs(k-l);
%     b=abs(k+l);
%     s=n-(a+b)/2;    
%     P = jacobiP(s,a,b,cos(beta));
%     B = sqrt(nchoosek(2*n-s,s+a)/nchoosek(s+b,b))*((1-cos(beta))/2)^(a/2)*((1+cos(beta))/2)^(b/2)*P;
%     ind = min(k,0)+min(l,0) + (k+l)*(l<k);
%     D(k+n+1,l+n+1) = (-1)^ind  *B;
%   end
% end
% 
% Wigner_D(n,beta)-D
%
% %% Wigner-D functions
% F = SO3FunHarmonic([zeros(1,9);eye(9)])
% reshape(F.eval(rotation.byEuler(pi/5,pi/3,pi/7)),3,3)
% sqrt(2*1+1) * Wigner_D(1,pi/3) .* exp(-1i*(-1:1)*pi/5) .* exp(-1i*(-1:1)'*pi/7)
%

