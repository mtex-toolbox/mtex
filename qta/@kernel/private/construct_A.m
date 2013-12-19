function [A,p] = construct_A(name,p,L)

A = ones(1,L+1);

switch lower(name)

  case {'bump','user'}

    A = calcChebyshevCoeff(construct_K(name,p,L),L,'maxangle',p);

  case 'laplace'

    A = Laplacekern(p,L);

  case 'abel poisson'

    for i=1:L, A(i+1) = (2*i+1)*exp(log(p)*2*i);end

  case 'de la vallee poussin'

    A(max(10,fix(p)+1):L+1) = []; L = min(L,max(10,fix(p)));
    A(2) = p/(p+2);

    for l=1:L-1, A(l+2) = ((p-l+1)*A(l)-(2*l+1)*A(l+1))/(p+l+2); end

    for l=0:L, A(l+1) = (2*l+1)*A(l+1); end

  case 'von mises fisher'
    
    b = besseli(0:L+1,p);
    A(2:end) = diff(b(2:end)) ./ (b(2)-b(1));
    
  case 'fibre von mises fisher'

    for i=1:L
      A(i+1) = (2*i+1)*sqrt(pi*p/2) * besseli(i+0.5,p)/sinh(p);
    end


  case 'square singularity'

    A(2) = (1+p^2)/2/p-1/log((1+p)/(1-p));

    for l=1:L-1
      A(l+2) = (-2*p*l*A(l)+(2*l+1)*(1+p^2)*A(l+1))/2/p/(l+1);
    end

    A = A .*(2*(0:L)+1);


  case 'local'

    A = localkern(p,3,L);

  case 'gauss weierstrass'

    for i=1:L, A(i+1) = (2*i+1)*exp(-i*(i+1)*p);end

  case 'dirichlet'

    if ~isnumeric(p), p = L;end
    A =  ones(1,round(p+1)).*(2*(0:round(p))+1);

  case 'fourier'

    A = p;

  case 'jackson'

    L = min(L,p);
    for l=1:L, A(l+1) = (2*l+1)*(1-l*(l+1)./(L*(L+1)));end

  case 'sobolev'

    A= (2*(0:L)+1) .* (0:L).^p .* (1:L+1).^p;

  case 'ghost'

    A =  p.^(0:L);


  case 'summability'

    L = p;
    A = zeros(1,L+1);
    N = fix(3*L/ 2);

    M = fix(L/2);

    A = zeros(N+M+1,1);
    for n = 0:N
      for m = 0:M


        for j= abs(m-n):(m+n)

          A(j+1) = A(j+1) + (2*n+1)* (2*m+1);

        end

      end
    end

    A = A ./ A(1);

  otherwise

    A = [];

end

if length(A) > 11 && ~any(strcmpi(name,{'Fourier','bump','Sobolev','ghost','summability'}))
  % prevent from instability effects
  epsilon = getMTEXpref('FFTAccuracy',1E-2);
  ind = find(A<=max(min([A,10*epsilon]),epsilon),1,'first');
  A = A(1:min([ind,length(A)]));
end
