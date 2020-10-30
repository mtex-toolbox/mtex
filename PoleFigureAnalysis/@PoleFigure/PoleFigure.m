classdef PoleFigure < dynProp & dynOption
%
% The class *PoleFigure* is used to store experimetnal pole figure
% intensitied, i.e., XRD, synchrotron or neuron data. It provides several
% <PoleFigureCorrection.html data correction methods> as well as the
% <PoleFigure2ODF.html reconstruction of an orientation density function
% (ODF)>. Importing pole figure data is explained in <PoleFigureImport.html
% this section>.
%
% Input
%  h     - crystal directions (@vector3d | @Miller)
%  r     - specimen directions (@S2Grid)
%  intensities - diffraction counts (double)
%  CS,SS - crystal, specimen @symmetry
%
% Options
%  superposition - weights for superposed crystal directions
%  background    - background intensities
%
% Class Properties
%  allH - cell of @Miller
%  allR - cell of @vector3d
%  allI - cell of diffraction intensities
%  c    - structure coefficients
%  SS   - specimen symmetry
%
% Dependent Class Properties
%  CS      - @crystalSymmetry
%  h       - @Miller direction of single pole figure
%  r       - specimen directions
%  intensities - diffraction intensities
%  antipodal - 
%
% See also
% ImportPoleFigureData loadPoleFigure loadPoleFigure_generic
% This section describes the class *PoleFigure* and gives an overview of
% the functionality MTEX offers to analyze pole figure data.

  properties
    allH = {}           % crystal directions
    allR = {}           % specimen directions
    allI = {}           % intensities
    c = {}              % structure coefficients for superposed pole figures
    SS = specimenSymmetry       % specimen symmetry
  end
   
  properties (Dependent = true)
    CS                  % crystal symmetry
    h                   % crystal direction of single pole figure
    r                   % specimen directions
    intensities         % diffraction intensities
    antipodal
  end
  
  methods
  
  
    function pf = PoleFigure(h,r,intensities,varargin)
      % constructor
      
      if nargin == 0, return;end
      
      pf.allH = ensurecell(h);
      pf.allR = ensurecell(r);
      if numel(pf.allR) == 1, pf.allR = repmat(pf.allR,size(pf.allH));end
      if ~check_option(varargin,'complete'), pf.allR{1}.antipodal = true;end      
      pf.allI = ensurecell(intensities);
            
      
      pf.c = ensurecell(get_option(varargin,'superposition',...
        cellfun(@(x) ones(1,length(x)),pf.allH,'uniformoutput',false)));
      
      % normalize structure coefficients
      %pf.c = cellfun(@(x) x./sum(x),pf.c,'uniformOutput',false);
            
      % extract symmetries
      pf.CS = getClass(varargin,'crystalSymmetry',pf.CS);
      pf.SS = getClass(varargin,'specimenSymmetry',pf.SS);
      
    end
    
    function pf = set.CS(pf,CS)
      
      for i = 1:length(pf.allH)
        pf.allH{i}.CS = CS;
      end
    end
        
    function CS = get.CS(pf)
      
      CS = pf.allH{1}.CS;
      
    end
    
    function h = get.h(pf)
      h = [pf.allH{:}];
    end
    
    function r = get.r(pf)
      try
        r = [pf.allR{:}];
      catch
        for i = 1:numel(pf.allR)
          pf.allR{i} = pf.allR{i}(:);
        end
        r = vertcat(pf.allR{:});
      end
    end
    
    function i = get.intensities(pf)
      try
        i = [pf.allI{:}];
      catch
        for i = 1:numel(pf.allI)
          pf.allI{i} = pf.allI{i}(:);
        end
        i = vertcat(pf.allI{:});
      end
    end
    
    function pf = set.intensities(pf,i)
      
      if numel(i) == 1
        for ipf = 1:numel(pf.allI)
          
          pf.allI{ipf} = i*ones(size(pf.allI{ipf}));
          
        end
      else
        cs = cumsum([0,cellfun('prodofsize',pf.allI)]);
        
        for ipf = 1:numel(pf.allI)
          pf.allI{ipf} = reshape(i(cs(ipf)+1:cs(ipf+1)),size(pf.allI{ipf}));
        end
      end
    end

    function out = get.antipodal(pf)
      out = pf.allR{1}.antipodal;
    end
    
    function pf = set.antipodal(pf,value)
      for i = 1:pf.numPF
        pf.allR{i}.antipodal = value;
      end
    end
    
    function varargout = size(pf,varargin)
      [varargout{1:nargout}] = size(pf.r,varargin{:});
    end
    
    function varargout = length(pf,ip)
      if nargin == 2
        if isempty(ip)
          varargout{1} = cellfun(@length,pf.allR);
        else
          [varargout{1:nargout}] = length(pf.allR{ip});
        end
      else
        [varargout{1:nargout}] = length(pf.r);
      end
    end
    
    function n = numPF(pf)
      n = numel(pf.allH);
    end
    
    function e = end(pf,i,n)
      % overloaded end function

      if n==1
        e = numel(pf.r);
      else
        e = size(pf.r,i);
      end
    end
    
  end
  
  methods (Static = true)
    [pf,interface,options] = load(fname,varargin)
  end
  
end
