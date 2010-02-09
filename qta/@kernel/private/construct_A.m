function A = construct_A(name,p,L)

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

    for i=1:L
      A(i+1) = (besseli(i,p)-besseli(i+1,p))/(besseli(0,p)-besseli(1,p));
    end
   

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
    
    A =  ones(1,round(p+1)).*(2*(0:round(p))+1);
    
  case 'fourier'
    
    A = p;

  case 'jackson'
    
    L = min(L,p);
    for l=1:L, A(l+1) = (2*l+1)*(1-l*(l+1)./(L*(L+1)));end
    
  otherwise
        
    A = [];

end

if length(A) > 11 && ~any(strcmpi(name,{'Fourier','bump'}))
  % prevent from instability effects
  epsilon = get_mtex_option('FFTAccuracy',1E-2);
  ind = find(A<=max(min([A,10*epsilon]),epsilon),1,'first');
  A = A(1:min([ind,length(A)]));
end
