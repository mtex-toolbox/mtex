classdef fibreVonMisesFisherKernel < SO3Kernel
  % the von Mises Fisher kernel of a fibre
  %
  % The kernel belonging to a fibre rather than to a single orientation - it
  % is what fibreODF convolves with. The concentration kappa may be given
  % directly or through a halfwidth.
  %
  % Syntax
  %   psi = fibreVonMisesFisherKernel(kappa)
  %   psi = fibreVonMisesFisherKernel('halfwidth',10*degree)
  %
  % Input
  %  kappa - concentration parameter, larger means sharper
  %
  % Output
  %  psi - @fibreVonMisesFisherKernel
  %
  % Options
  %  halfwidth - halfwidth instead of kappa
  %  bandwidth - maximum harmonic degree
  %
  % Class Properties
  %  kappa     - concentration parameter
  %  A         - Chebyshev coefficients
  %  bandwidth - maximum harmonic degree
  %
  % See also
  % SO3Kernel SO3vonMisesFisherKernel fibreODF
  %
      
  properties
    kappa = 45;
  end
      
  methods
    
    function psi = fibreVonMisesFisherKernel(varargin)
      
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')        
        hw = get_option(varargin,'halfwidth');        
        psi.kappa = log(2) / (1-cos(hw));
      elseif nargin > 0
        psi.kappa = varargin{1};
      end            
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
                 
      % compute Legendre coefficients
      psi.A = ones(L+1,1);
      for i=1:L
        psi.A(i+1) = (2*i+1)*sqrt(pi*psi.kappa/2) *...
          besseli(i+0.5,psi.kappa)/sinh(psi.kappa);
      end      

      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['fibre von Mises Fisher kernel, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
         
    function S2K = radon(psi)
      % the radon transformed kernel function
      
      S2K = S2Kernel(psi.A,@evalRadon);
      
      function value = evalRadon(t)
        t = cut2unitI(t);
        value = psi.kappa/sinh(psi.kappa)*exp(psi.kappa*t);
      end
    end
    
% double radon transform used in calcPDF
%     function value = RRK(psi,dh,dr)
%       dh = cut2unitI(dh);
%       dr = cut2unitI(dr);
%       value = psi.kappa/sinh(psi.kappa) * ...
%         besseli(0,psi.kappa * sqrt((1-dh.^2)*(1-dr.^2))).*...
%         exp(psi.kappa * dh * dr);
%     end
  end
end
