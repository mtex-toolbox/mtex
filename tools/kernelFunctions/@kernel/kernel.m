classdef kernel
% 
  
  properties
    A=[] % Chebyshev coefficients
  end
  
  methods
  
    % constructor
    function psi = kernel(A)
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
                
    function value = K(psi,co2)
      % use the Clenshaw algorithm to compute the kernel value from the
      % Chebyshev coefficients
      
      co2 = cut2unitI(co2);
      value = ClenshawU(psi.A,acos(co2)*2);
      
      function res = ClenshawU(A,omega)
        % calcualtes sum A_l Tr T_l(omega)

        omega = omega / 2;
        U = ones(size(omega));
        res = A(1) * U;

        for l=1:length(A)-1
          U = cos(2*l*omega) + cos(omega).*cos((2*l-1)*omega) ...
            + cos(omega).^2.*U;
          res = res + A(l+1) * U;
        end      
      end
    end
    
    function value = RK(psi,d)
      % use the Clenshaw algorithm to compute the kernel value from the
      % Legendre coefficients
      
      d = cut2unitI(d);
      value = ClenshawL(psi.A,d);
      
      function s = ClenshawL(c,x)
        % Clenshaw-Algorithmus zum Aufsummieren von legendrepolynomen

        % x - Auswertungspunkte
        % c - Koeffizienten
        
        % Initialisierung
        dn = repmat(c(end),size(x));
        d1 = zeros(size(x));
        d2 = zeros(size(x));

        for l = length(c)-2:-1:1
        
          d1 = d2 + (2*l+1)/(l+1) * x .* dn;
          d2 = c(l) - l/(l+1) * dn;
          dn = d1;
    
          %c(l+1) = c(l+1) + (2*l+1)/(l+1)*x*c(l+2);
          %c(l) =  c(l) - l/(l+1)*c(l+2);
        end

        dn = d2 + x .* d1;
        s = dn;
      end  
    end
    
    function value = RRK(psi,dh,dr)
      % use the Clenshaw algorithm to compute the kernel value from the
      % Legendre coefficients
     
      dh = cut2unitI(dh);
      dr = cut2unitI(dr);
      value = zeros(numel(dh),numel(dr));
      if numel(dh)<numel(dr)
        for ih = 1:length(dh)
          Plh = legendre0(length(psi.A)-1,dh(ih));
          value(ih,:) = ClenshawL(psi.A(:) .* Plh,dr);
        end
      else
        for ir = 1:length(dr)
          Plr = legendre0(length(psi.A)-1,dr(ir));
          value(:,ir) = ClenshawL(psi.A(:) .* Plr,dh).';
        end
      end
      value(value<0)=0;
    end
      
    function value = eq(psi1,psi2)
      % check for equal kernel functions      
      
      L = min(psi1.bandwith,psi2.bandwith);
      
      value = norm(psi1.A(1:L) - psi2.A(1:L)) ./ norm(psi1.A) < 1e-6;
    end
    
    function bw = bandwidth(psi)
      % get bandwidth
      bw = length(psi.A)-1;
    end
    
    function n = norm(psi)
      % L2 norm
      n = norm(psi.A.^2);
    end
    
    function psi = mtimes(psi1,psi2)
      % convolution of kernel functions
            
      L = min(psi1.bandwidth,psi2.bandwidth);     
      l = 0:L;

      psi = kernel(psi1.A(1:L+1) .* psi2.A(1:L+1) ./ (2*l+1));    
    end
         
    function psi = mpower(psi,p)
      % self convolution

      l = 0:psi.bandwidth;
      psi = kernel((psi.A ./ (2*l+1)).^p .* (2*l+1));      
    end
    
    function hw = halfwidth(psi)
      hw = fminbnd(@(omega) (psi.K(1)-2*psi.K(cos(omega/2))).^2,0,3*pi/4);
    end

  end
  
  methods (Access=protected)
           
    function A = cutA(psi)
      % cut of Chebyshev coefficients when they are sufficently small
      
      epsilon = getMTEXpref('FFTAccuracy',1E-2);
      A = psi.A(:);
      ind = find(A(2:end)<=max(min([A(2:end);10*epsilon]),epsilon),1,'first');
      A = A(1:min([ind+1,length(A)]));
    end
    
    function A = calcFourier(psi,L,maxAngle)
      
      if nargin == 2, maxAngle = pi;end      
      epsilon = getMTEXpref('FFTAccuracy',1E-2);
      small = 0;      
      warning off; %#ok<*WNOFF>
      
      for l = 0:L
        fun = @(omega) psi.K(cos(omega/2)).*sin((2*l+1)*omega./2).*sin(omega./2);
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

