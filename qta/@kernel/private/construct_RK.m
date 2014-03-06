function RK = construct_RK(name,p,A)
%
%
% here dmatrix is 

switch lower(name)
  
  case {'laplace','local','fourier','gauss weierstrass','dirichlet','user','jackson'}
    
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
    
  case 'bump'
    
    RK = @(dmatrix) Rbump(dmatrix,p);
    
  otherwise    

    RK  = @(dmatrix) ClenshawL(A,dmatrix);
    
    %RK = [];
    
end

function RK = Rbump(dmatrix,p)

RK = zeros(size(dmatrix));
s = cos(p/2)./sqrt((1+dmatrix)./2);
ind = s<=1;
RK(ind) = (pi/(p-sin(p)))*2/pi*acos(s(ind));
