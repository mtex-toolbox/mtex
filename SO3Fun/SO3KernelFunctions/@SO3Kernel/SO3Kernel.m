classdef SO3Kernel
% 
% The class *SO3Kernel* is needed in MTEX to define the specific form of
% unimodal ODFs. It has to be passed as an argument when calling the
% methods <uniformODF.html uniformODF>. 
% For more information take a look at the <SO3Kernels.html documentation>.
%
% A kernel is a radially symmetric function on SO(3) and is stored by its
% Chebyshev coefficients A. Deriving classes give A a closed form, the
% arithmetics and the evaluation are inherited from here.
%
% Syntax
%   psi = SO3Kernel(A)
%   psi = SO3Kernel(fun)
%
% Input
%  A   - Chebyshev coefficients
%  fun - @function_handle, gives an @SO3KernelHandle
%
% Output
%  psi - @SO3Kernel
%
% Class Properties
%  A         - Chebyshev coefficients
%  bandwidth - maximum harmonic degree
%
% Derived Classes
%  @SO3DeLaValleePoussinKernel - de la Vallee Poussin kernel
%  @SO3AbelPoissonKernel       - Abel Poisson kernel
%  @SO3vonMisesFisherKernel    - von Mises Fisher kernel
%  @SO3GaussWeierstrassKernel  - Gauss Weierstrass kernel
%  @SO3BumpKernel              - indicator function of a ball
%  @SO3KernelHandle            - kernel given by a function handle
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
    function psi = SO3Kernel(A,varargin)
      
      if nargin==0
        psi.A=0;
        return
      end
      if isa(A,'function_handle')
        psi = SO3KernelHandle(A,varargin{:});
        return
      end
      if isa(A,'SO3Kernel')
        psi = A;
        return
      end

      psi.A = A(:);
      %psi.A = cutA(psi);
      
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
      if L>psi.bandwidth
        psi.A = [psi.A(:);zeros(L-psi.bandwidth,1)];
      else
        psi.A = psi.A(1:L+1);        
      end
    end
    
    function n = norm(psi)
      % L2 norm
      n = norm(psi.A);
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
    
  end
end

