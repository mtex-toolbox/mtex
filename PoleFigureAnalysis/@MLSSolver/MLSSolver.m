classdef MLSSolver < handle
  % modified least squares solver MLSSOLVER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    pf  % poleFigure data       
    psi  % kernel function
    S3G  % SO3Grid
    c    % current coefficients
    weights % cell
  end
  
  properties %(Access = private)
    nfft_gh % list of nfft plans
    nfft_r  % list of nfft plans
    A       % legendre coefficients of the kernel function
    refl    % cell
    u
    a
    alpha
  end
  
  properties (Dependent = true)
    odf % the reconstructed @ODF
  end
  
  
  
  methods
    function obj = MLSSolver(varargin)
      
    end

    
    function odf = get.odf(solver)
      odf = unimodalODF(solver.S3G,solver.psi,'weights',solver.c./sum(solver.c));
    end
    
    
  end
  
  methods (Static = true)
    
    function check
      
      cs = crystalSymmetry('1');
      odf = unimodalODF(orientation('Euler',20*degree,40*degree,60*degree,cs));
      r = equispacedS2Grid('upper','antipodal');
      h = Miller({1,0,0},{1,1,1},{1,1,0},cs);
      pf = calcPoleFigure(odf,h,r);
      
      mtexdata dubna
      tic
      solver = MLSSolver;
      solver.pf = pf;
      solver.S3G = equispacedSO3Grid(pf.CS,'resolution',5*degree);
      solver.psi = deLaValeePoussinKernel('halfwidth',5*degree);
      solver.weights = repcell(1,numPF(pf),1);
      solver.c = ones(length(solver.S3G),1) ./ length(solver.S3G);
      
      solver.init
      solver.initIter
      for i = 1:10, solver.doIter; end
      delete(solver);
      toc
      
      
    end
    
  end
  
end

