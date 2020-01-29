classdef MLSSolver < pf2odfSolver
% 
% The class MLSSolver implements the modified least squares solver for
% reconstructing an ODF from arbitrarily scattered pole figure intensities.
% The resulting ODF is represented as a weighted sum of unimodal
% components. The shape and the number of component centers can be
% specified. The algorithm is explained in detail in *A novel pole figure
% inversion method: specification of the MTEX algorithm*, Hielscher,
% Schaeben: J. of Appl. Cryst., 41(6), 2008.
%
% Syntax
%
%   solver = MLSSolver(pf,'resolution',5*degree,'halfwidth',7.5*degree);
%   [odf,alpha] = solver.calcODF;
%
% Class Properties
%  psi     - @kernel describing the shape of the unimodal components
%  S3G     - the centers of the unimodal components as @SO3Grid in orientation space
%  c       - weighting coefficients to the unimodal components
%  weights - 
%  zrm     - @zeroRangeMethod
%  ghostCorrection - whether to use ghost correction
%  iterMax - max number of iterations
%  iterMin - min number of iterations
%
% Dependent Class Properties
%  odf - @ODF the reconstructed ODF
%
% See also
% PoleFigureTutorial PoleFigure2ODFAmbiguity PoleFigure2ODFGhostCorrection

  properties
    psi     % kernel function
    S3G     % SO3Grid
    c       % current coefficients
    weights % cell
    zrm     % zero range method
    ghostCorrection = 1
    iterMax = 10; % max number of iterations
    iterMin = 5; % max number of iterations
  end
  
  properties (Access = private)
    nfft_gh  % list of nfft plans
    nfft_r   % list of nfft plans
    A        % legendre coefficients of the kernel function
    refl     % cell
    u
    a
    alpha
  end
  
  properties (Dependent = true)
    odf % the reconstructed @ODF
  end
    
  methods
    function solver = MLSSolver(pf,varargin)
      % constructor
      
      if nargin == 0, return; end
      
      % ensure intensities are non negative
      %solver.pf = unique(max(pf,0));
      solver.pf = max(pf,0);

      % normalize very different polefigures
      mm = max(pf.intensities(:));

      for i = 1:pf.numPF
        if mm > 5*max(pf.allI{i}(:))
          pf.allI{i} = pf.allI{i} * mm/5/max(pf.allI{i}(:));
        end
      end
      
      % generate discretization of orientation space
      solver.S3G = getClass(varargin,'SO3Grid');
      if isempty(solver.S3G)
        if pf.allR{1}.isOption('resolution')
          res = pf.allR{1}.resolution;
        else
          res = 5*degree;
        end
        res = get_option(varargin,'resolution',res);
        solver.S3G = equispacedSO3Grid(solver.pf.CS,solver.pf.SS,'resolution',res);
      end
      
      % zero range method
      if check_option(varargin,{'ZR','zero_range','zeroRange'})
        solver.zrm = zeroRangeMethod(solver.pf);
      end
        
      % get kernel
      psi = deLaValleePoussinKernel('halfwidth',...
        get_option(varargin,{'HALFWIDTH','KERNELWIDTH'},solver.S3G.resolution,'double'));
      solver.psi = getClass(varargin,'kernel',psi);
            
      % get other options
      solver.iterMin = get_option(varargin,'iterMin',solver.iterMin);
      solver.iterMax = get_option(varargin,'iterMax',solver.iterMax);
  
      % start vector
      solver.c = get_option(varargin,'C0',[]);
      
      % ghost correction
      solver.ghostCorrection = ~check_option(varargin,'noGhostCorrection');

      % compute quadrature weights
      if numProper(solver.SS) == 1
        solver.weights = cellfun(@(r) calcQuadratureWeights(r),solver.pf.allR,'UniformOutput',false);
      else
        solver.weights = num2cell(1./length(pf,[]));
      end
    end

    function delete(solver)
      % destructor

      % free all nfft plans
      for i = 1:length(solver.nfft_gh)
        nfsftmex('finalize',solver.nfft_gh(i));
      end

      for i = 1:length(solver.nfft_r)
        nfsftmex('finalize',solver.nfft_r(i));
      end

    end
    
    function odf = get.odf(solver)
      odf = unimodalODF(solver.S3G,solver.psi,'weights',solver.c./sum(solver.c));
    end
    
  end
  
  methods (Static = true)
    
    function check
      
      cs = crystalSymmetry('222');
      odf = unimodalODF(orientation.id(cs));
      r = equispacedS2Grid('upper','antipodal','resolution',5*degree);
      h = Miller({1,0,0},{1,1,1},{1,1,0},cs);
      pf = calcPoleFigure(odf,h,r);
      odf = calcODF(pf)
      
      plotPDF(odf,h)
      plotFibre(odf,fibre.alpha(cs))
      
      mtexdata dubna
      tic
      solver = MLSSolver;
      solver.pf = pf;
      solver.S3G = equispacedSO3Grid(pf.CS,'resolution',2.5*degree);
      solver.psi = deLaValleePoussinKernel('halfwidth',2.5*degree);
      solver.weights = repcell(1,numPF(pf),1);
      solver.c = ones(length(solver.S3G),1) ./ length(solver.S3G);
      
      solver.init
      odf = solver.calcODF;
      delete(solver);
      toc
      
    end
    
  end
  
end
