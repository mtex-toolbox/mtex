classdef SO3FunCBF < SO3Fun
% a class representing fibre symmetric ODFs
%
% Syntax
%   SO3F = SO3FunCBF(h,r,weights,psi)
%   SO3F = SO3FunCBF(fibre,'halfwidth',10*degree)
%
% Input
%  h       - @vector3d
%  r       - @vector3d
%  weights - double
%  psi     - @S2Kernel
%  fibre   - @fibre
%
% Output
%  SO3F - @SO3FunCBF
%
% Example
%
%   cs = crystalFrame.load("Mg-Magnesium.cif");
%   fibre = fibre.beta(cs);
%   SO3F = SO3FunCBF(fibre,'halfwidth',10*degree)
%

  properties
    h
    r
    psi = S2DeLaValleePoussinKernel('halfwidth',10*degree);
    weights = 1;
    % TODO: antipodal wird weder erkannt noch gesetzt/verwendet
    antipodal = false;
  end

  properties (Dependent = true)
    frameB
    frameA
    bandwidth % harmonic degree
    isReal
  end
  
  methods
    function SO3F = SO3FunCBF(varargin)
      
      if nargin == 0, return;end
      
      if isa(varargin{1},'fibre')
        f = varargin{1};
        SO3F.h = f.h;
        SO3F.r = f.r;
        wPos = 2;
      else
        wPos = 3;
        SO3F.h = varargin{1};
        SO3F.r = varargin{2};
      end

      if nargin>=wPos && isnumeric(varargin{wPos})
        SO3F.weights = varargin{wPos};
      else
        n = max(numel(SO3F.h),numel(SO3F.r));
        SO3F.weights = ones(n,1) / n;
      end

      hw = get_option(varargin,'halfwidth',10*degree);
      SO3F.psi = getClass(varargin,'S2Kernel',S2DeLaValleePoussinKernel('halfwidth',hw));
      SO3F.SS = getClass(varargin,'specimenFrame',specimenFrame.default);
                  
    end
    
    function SO3F = set.frameA(SO3F,frameA)
      if isa(frameA,'crystalFrame')
        SO3F.h = Miller(SO3F.h,frameA);
      else
        SO3F.h = vector3d(SO3F.h);
        SO3F.h.opt.sym = frameA;
      end
    end
    
    function frameA = get.frameA(SO3F)
      if isCrystalDirection(SO3F.h)
        frameA = SO3F.h.CS;
      else
        try
          frameA = SO3F.h.opt.sym;
        catch
          frameA = specimenFrame.default;
        end
      end
    end
    
    function SO3F = set.frameB(SO3F,frameB)
      if isa(frameB,'crystalFrame')
        SO3F.r = Miller(SO3F.r,frameB);
      else
        SO3F.r = vector3d(SO3F.r);
        SO3F.r.opt.sym = frameB;
      end      
    end
    
    function frameB = get.frameB(SO3F)
      if isCrystalDirection(SO3F.r)
        frameB = SO3F.r.CS;
      else
        try
          frameB = SO3F.r.opt.sym;
        catch
          frameB = specimenFrame.default;
        end
      end
    end
    
    function L = get.bandwidth(SO3F)
      L= SO3F.psi.bandwidth;
    end
    
    function SO3F = set.bandwidth(SO3F,L)
      SO3F.psi.bandwidth = L;
    end
    
    function out = get.isReal(f)
      out = isreal(f.weights);
    end
  
    function F = set.isReal(F,value)
      if ~value, return; end
      F.weights = real(F.weights);
    end

  end 
  
  methods (Static = true)
  
    SO3F = example(varargin)
    
  end

end
