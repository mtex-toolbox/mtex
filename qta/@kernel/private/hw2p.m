function p = hw2p(name,hw)
% (kernel,halfwidth) -> parameter

switch lower(name)
            
	case 'abel poisson'
   
    p = fminbnd(@(t) (p2hw(name,t)-hw)^2,0,1);
    
	case 'de la vallee poussin'
                
		p = 0.5 * log(0.5) / log(cos(hw/2));

	case 'von mises fisher'

    p = log(2) / (1-cos(hw));
    
  case 'fibre von mises fisher'

		p = log(2) / (1-cos(hw));
    
	case 'local'

		p = cos(hw);
    
  case 'bump'
    
    p = hw;
    
  case 'gauss weierstrass'
    
    p = fminbnd(@(t) (p2hw(name,t)-hw)^2,0,1);

  case 'dirichlet'
    
    p = 2/hw;
    
  otherwise

		p = fminsearch(@(t) (p2hw(name,max(t,0))-hw)^2,0.5);
    
end
