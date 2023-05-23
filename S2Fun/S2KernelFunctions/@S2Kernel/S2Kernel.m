classdef S2Kernel
% The class *S2Kernel* is needed in MTEX to define the specific form of
% fibre ODFs. It has to be passed as an argument when calling the
% methods <fibreODF.html fibreODF>.
% For more information take a look at the <S2Kernels.html documentation>.
%
% See also
% S2DeLaValleePoussinKernel S2BumpKernel

  properties
    A % Legendre coefficients
  end

  properties (Dependent=true)
    bandwidth % harmonic degree
  end
  
  properties (Hidden = true)
    evalFun = []
  end
  
  
  methods
    
    function S2K = S2Kernel(A, varargin)
      if nargin == 0, return; end
      
      if isa(A,'S2Kernel')
        S2K.A = A.A;
      else
        S2K.A = A(1:min(end,2048));
      end
      
      if check_option(varargin,'normalized')
        S2K.A = S2K.A(:) .* (2*(0:length(S2K.A)-1)+1).';
      end

      if nargin == 2 && isa(varargin{1},'function_handle')
        S2K.evalFun = varargin{1}; 
      end
    end

    function v = eval(S2K,x)
      % evaluate the kernel function at nodes x
    
      % TODO: make this faster using a polynomial transform and a nfct
      if isempty(S2K.evalFun)
        v = ClenshawL(S2K.A,x);
      else
        v = S2K.evalFun(x);
      end
    end

    function plot(S2K,varargin)      
      
      if check_option(varargin,{'3d','surf'})
        plot(S2FunHarmonic(S2K),varargin{:});
        return
      end

      omega = get_option(varargin,'omega',linspace(0,180*degree,1000));
      
      f = S2K.eval(cos(omega));
      
      if check_option(varargin,'symmetric')
        omega = [-fliplr(omega),omega];
        f = [fliplr(f),f];
      end
      
      optiondraw(plot(omega./degree,f),varargin{:});
      xlim(gca,[min(omega),max(omega)]./degree)

    end
    
    function surf(S2K,varargin)
      surf(S2FunHarmonic(S2K),varargin{:});
    end
    
    function display(S2K)
      displayClass(S2K,inputname(1));
      disp(['  bandwidth: ',int2str(S2K.bandwidth)]);
      try
        disp(['  halfwidth: ',xnum2str(S2K.halfwidth/degree) mtexdegchar]);
      end
      disp(' ');
    end

    function L = get.bandwidth(psi)
      L = length(psi.A)-1;
    end
    
    function psi = set.bandwidth(psi,L)
      psi.A = psi.A(1:min(L+1,end));        
    end

    function c = char(psi)
      c = ['custom, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end

    function hw = halfwidth(psi)
      hw = fminbnd(@(t) (psi.eval(1)-2*psi.eval(cos(t))).^2,0,3*pi/4);
    end
    
    
  end

  methods (Static = true)
    function S2K = quadrature(fun,varargin)
      
      % TODO: implement this using the fpt and the ndct
      t = chebfun(fun);
      B = chebcoeffs(t);
      A = cheb2leg(B);
      S2K = S2Kernel(A);          
      
      % initialize the fast polynomial transform
            
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
      
      if nargin==2, maxAngle=pi; end

      epsilon = eps;%getMTEXpref('FFTAccuracy',1E-2);
      small = 0;      

      % Get nodes and weights for Gauss-Legendre quadrature
      [nodes,weights] = GaussLegendreNodesWeights(L+1,cos(maxAngle),1);
%       % Get better accuracy by double sampling rate
%       [nodes,weights] = GaussLegendreNodesWeights(2*L,-1,1);

      values = psi.eval(nodes);

      % Evaluate Legendre polynomials up to degree N
      v = legendre0(L,nodes);

      for l = 0:L
        A(l+1) =  sum((2*l+1)/2*values.*weights.*v(l+1,:).');    
        
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