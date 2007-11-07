function p = hw2p(name,hw)
% (kernel,halfwidth) -> parameter

switch name
            
	case 'Abel Poisson'
   
    p = fminbnd(@(t) (p2hw(name,t)-hw)^2,0,1);
    
	case 'de la Vallee Poussin'
                
		p = 0.5 * log(0.5) / log(cos(hw/2));

	case 'von Mises Fisher'

    p = log(2) / (1-cos(hw));
    
  case 'fibre von Mises Fisher'

		p = log(2) / (1-cos(hw));
    
	case 'local'

		p = cos(hw);
    
  case 'Gauss Weierstrass'
    
    p = fminbnd(@(t) (p2hw(name,t)-hw)^2,0,1);

  otherwise

		p = fminsearch(@(t) (p2hw(name,max(t,0))-hw)^2,0.5);
    
end
