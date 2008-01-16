function RK = construct_RK(name,p,A)

switch lower(name)
  
  case {'laplace','local','user','gauss weierstrass','dirichlet','user'}
    
    RK  = @(dmatrix) ClenshawL(A,dmatrix);

  case 'abel poisson'

    RK  = @(dmatrix) (1-p^4)./((1-2*p^2*dmatrix+p^4).^(3/2));

  case 'de la vallee poussin'

    RK  = @(dmatrix) (1+p) * ((1+dmatrix)/2).^p;

  case 'von mises fisher'
      
      RK  = @(dmatrix) exp(p*(dmatrix-1)/2) .* ...
        besseli(0,p *(1+dmatrix)/2)/...
        (besseli(0,p)-besseli(1,p));

  case 'fibre von mises fisher'

    RK  = @(dmatrix) p/sinh(p)*exp(p*dmatrix);
    
  case 'square singularity'
    
    RK  = @(dmatrix) 2*p/log((1+p)/(1-p)) ./ (1-2*p*dmatrix+p^2);
    
  otherwise    

    RK = [];
    
end
