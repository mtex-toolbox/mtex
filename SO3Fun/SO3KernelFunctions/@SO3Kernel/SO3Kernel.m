classdef SO3Kernel
% 
% The class *SO3Kernel* is needed in MTEX to define the specific form of
% unimodal ODFs. It has to be passed as an argument when calling the
% methods <uniformODF.html uniformODF>. 
% For more information take a look at the <SO3Kernels.html documentation>.
%
% See also
% SO3DeLaValleePoussinKernel SO3AbelPoissonKernel
  
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
      
      L = min(psi1.bandwidth,psi2.bandwidth);
      
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
         
    function c = char(psi)
      c = ['custom, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function psi =  mpower(psi,varargin) %#ok<INUSD>
      % self convolution
      error(['Operator ''*'' is not supported for operands of type ''SO3Kernel''. Use ' ...
        'conv() instead.'])
      % l = 0:psi.bandwidth;
      % psi = SO3Kernel((psi.A ./ (2*l+1)).^p .* (2*l+1));      
    end
    
    function hw = halfwidth(psi)
%       hw = fminbnd(@(omega) (psi.eval(1)-2*psi.eval(cos(omega/2))).^2,0,3*pi/4);
      % Minimization does not yield first/global minimizer, so:
      % Find halfwidth by function evaluations
      
      if psi.A==0
        hw = 0;
        return
      end

      if psi.bandwidth<100 
        epsilon = 0.01;
      else
        epsilon = 0.1;
      end
      
      % evaluate psi
      v = abs(psi.eval(cos((0:epsilon:180)*degree/2)));
      % get maximum value
      [my,mind] = max(v);
%       shift
%       v = [flip(v(2:end));v];
%       mx = (mind-1)*epsilon;
      % shift halfwide to roots
      v = my-2*v;
      
      hr = find(v(mind:end)>=0,1,'first')-1;
      if isempty(hr), hr=0; end
      hl = mind-find(v(1:mind)>=0,1,'last');
      if isempty(hl), hl=0; end
      hw = max(hl,hr)*epsilon*degree;
      

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

