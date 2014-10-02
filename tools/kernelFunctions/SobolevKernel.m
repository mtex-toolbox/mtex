classdef SobolevKernel < kernel
    
  properties
    s = 1;
  end
      
  methods
    
    function psi = SobolevKernel(s,varargin)
      
      if nargin == 0, return;end
      psi.s = s;
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
       
      psi.A = (2*(0:L)+1) .* (0:L).^psi.s .* (1:L+1).^psi.s;

      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Sobolev, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
  end

end
