classdef SO3Kernel
% 
% The class *SO3Kernel* is needed in MTEX to define the specific form of
% unimodal ODFs. It has to be passed as an argument when calling the
% methods <uniformODF.html uniformODF>.
%
% See also
% SO3deLaValeePoussin SO3AbelPoisson
  
  properties
    A=[] % Chebyshev coefficients
  end

  properties (Dependent=true)
    bandwidth % harmonic degree
  end
    
  
  methods
  
    % constructor
    function psi = SO3Kernel(A)
      if nargin > 0
        psi.A = A(:);
        %psi.A = cutA(psi);
      end
    end
  
    % standard output
    function display(psi)
      displayClass(psi,inputname(1));      
      disp(['  bandwidth: ',int2str(psi.bandwidth)]);
      disp(['  halfwidth: ',xnum2str(psi.halfwidth/degree) mtexdegchar]);      
      disp(' ');
    end
                         
    function value = eq(psi1,psi2)
      % check for equal kernel functions      
      
      L = min(psi1.bandwith,psi2.bandwith);
      
      value = norm(psi1.A(1:L) - psi2.A(1:L)) ./ norm(psi1.A) < 1e-6;
    end
    
    
    function L = get.bandwidth(psi)
      L = length(psi.A)-1;
    end
    
    function psi = set.bandwidth(psi,L)
      psi.A = psi.A(1:min(L+1,end));        
    end
    
    function n = norm(psi)
      % L2 norm
      n = norm(psi.A.^2);
    end
    
    function psi = mtimes(psi1,psi2)
      % convolution of kernel functions            
      psi = conv(psi1,psi2);
    end
         
    function c = char(psi)
      c = ['custom, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function psi = mpower(psi,p)
      % self convolution

      l = 0:psi.bandwidth;
      psi = SO3Kernel((psi.A ./ (2*l+1)).^p .* (2*l+1));      
    end
    
    function hw = halfwidth(psi)
      hw = fminbnd(@(omega) (psi.eval(1)-2*psi.eval(cos(omega/2))).^2,0,3*pi/4);
    end

  end
  
  methods (Access=protected)
           
    function A = cutA(psi)
      % cut of Chebyshev coefficients when they are sufficently small
      
      epsilon = getMTEXpref('FFTAccuracy',1E-2) / 150;
      A = psi.A(:);
      A = A ./ ((1:length(A)).^2).';
      ind = find(A(2:end)<=max(min([A(2:end);10*epsilon]),epsilon),1,'first');
      A = psi.A(1:min([ind+1,length(A)]));
    end
    
    function A = calcFourier(psi,L,maxAngle)
      
      if nargin == 2, maxAngle = pi;end      
      epsilon = getMTEXpref('FFTAccuracy',1E-2);
      small = 0;      
      warning off; %#ok<*WNOFF>
      
      for l = 0:L
        fun = @(omega) psi.eval(cos(omega/2)).*sin((2*l+1)*omega./2).*sin(omega./2);
        A(l+1) = 2/pi*quadgk(fun ,0,maxAngle,'MaxIntervalCount',2000); %#ok<AGROW>
        
        if abs(A(l+1)) < epsilon
          small = small + 1;
        else
          small = 0;
        end
        
        if small == 10, break;end
      end
    end
    
  end
end

