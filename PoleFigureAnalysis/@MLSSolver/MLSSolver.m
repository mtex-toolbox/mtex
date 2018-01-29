classdef MLSSolver < handle
  %MLSSOLVER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    pf   % @poleFigure data
    
    psi  % @kernel 
    
    c % current coefficients
    gh
  end
  
  properties (Private = true)
    nfft_gh % list of nfft plans
    nnft_r  % list of nfft plans
  end
  
  properties (Dependent = true)
  end
  
  
  
  methods
    function obj = MLSSolver(pf)
      %MLSSOLVER Construct an instance of this class
      %   Detailed explanation goes here
      obj.Property1 = inputArg1 + inputArg2;
    end
    
    function outputArg = method1(obj,inputArg)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      outputArg = obj.Property1 + inputArg;
    end
  end
end

