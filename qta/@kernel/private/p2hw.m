function hw = p2hw(name,p)
% kernel parameter to halfwidth

switch lower(name)

	%case 'Abel Poisson'
  %  
  %  K = getK(kernel(name,p));
  %  hw = fminbnd(@(omega) (0.5*K(1)-K(cos(omega/2)))^2,0,pi/2);

	case 'de la vallee poussin'

		hw = 2*acos(0.5^(1/2/p));

	case 'von mieses fisher'

    hw = acos(1-log(2)/p);

  case 'fibre von mises fisher'

    hw = acos(1-log(2)/p);

	case 'local'

  	hw = acos(p);
    
  case 'bump'
        
  	hw = p;

  case {'user','sobolev','ghost'}
    
    hw = pi;
    
  otherwise

    K = construct_K(name,p,construct_A(name,p,1000));

    hw = abs(fzero(@(omega) 0.5*K(1)-K(cos(omega/2)),0));

end
