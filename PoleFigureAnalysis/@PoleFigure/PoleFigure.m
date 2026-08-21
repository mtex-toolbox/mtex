classdef PoleFigure < dynProp & dynOption
%
% The class *PoleFigure* is used to store experimental pole figure
% intensities, i.e., XRD, synchrotron or neuron data. It provides several
% <PoleFigureCorrection.html data correction methods> as well as the
% <PoleFigure2ODF.html reconstruction of an orientation density function
% (ODF)>. Importing pole figure data is explained in <PoleFigureImport.html
% this section>.
%
% Input
%  h - @Miller, crystal directions
%  r - @S2Grid, specimen directions
%  intensities - diffraction counts (double)
%  CS - @crystalSymmetry
%  SS - @specimenSymmetry
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
  end

  properties (Hidden = true)
    % the specimen symmetry, empty while none was given - then SS follows the session
    SSprivate = []
  end

  properties (Dependent = true)
    SS                  % specimen symmetry
    CS                  % crystal symmetry
    h                   % crystal direction of single pole figure
    r                   % specimen directions
    intensities         % diffraction intensities
    antipodal
    frame               % the specimen reference frame (carried by allR)
    how2plot            % plotting convention - read only
    % a convention belongs to a reference frame, see plottingConvention.default
  end
  
  methods
  
  
    function pf = PoleFigure(h,r,intensities,varargin)
      % constructor
      
      if nargin == 0, return;end
      
      pf.allI = ensurecell(intensities);
      if iscell(h)
        pf.allH = h;
      elseif isscalar(pf.allI)
        pf.allH = {h};
      else
        pf.allH = vec2cell(h);
      end
      pf.allR = ensurecell(r);
      if isscalar(pf.allR), pf.allR = repmat(pf.allR,size(pf.allH));end
      if ~check_option(varargin,'complete'), pf.allR{1}.antipodal = true;end      
      
      pf.c = ensurecell(get_option(varargin,'superposition',...
        cellfun(@(x) ones(1,length(x)),pf.allH,'uniformoutput',false)));
      
      % normalize structure coefficients
      %pf.c = cellfun(@(x) x./sum(x),pf.c,'uniformOutput',false);
            
      % extract symmetries
      pf.CS = getClass(varargin,'crystalSymmetry',pf.CS);
      % only a symmetry that was actually given is stored - otherwise SS
      % keeps following the session default
      pf.SSprivate = getClass(varargin,'specimenSymmetry',pf.SSprivate);
      
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    function pf = set.CS(pf,CS)
      
      for i = 1:length(pf.allH)
        pf.allH{i}.CS = CS;
      end
    end
        
    function CS = get.CS(pf)
      CS = pf.allH{1}.CS;
    end
    
    function ss = get.SS(pf)
      ss = pf.SSprivate;
      if isempty(ss), ss = specimenSymmetry.default; end
    end

    function pf = set.SS(pf,ss)
      pf.SSprivate = ss;
    end

    function fr = get.frame(pf)
      fr = pf.allR{1}.frame;
    end

    function pf = set.frame(pf,fr)
      for k=1:length(pf.allR)
        pf.allR{k}.frame = fr;
      end
      % the symmetry has to move with the data - fork it, an unset SS is shared
      if ~isempty(fr) && (isempty(pf.SSprivate) || pf.SSprivate.frame ~= fr)
        ss = copy(pf.SS);
        ss.frame = fr;
        pf.SSprivate = ss;
      end
    end

    function pC = get.how2plot(pf)
      pC = pf.allR{1}.how2plot;
    end


    function h = get.h(pf)
      h = pf.allH;
      h = horzcat(h{:});
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
      
      if isscalar(i)
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

    function pf = loadobj(pf)
      % called by Matlab when an object is loaded from an .mat file
      %
      % a loaded file does not change how the session plots - see
      % EBSD/loadobj. The pole figure keeps the frame it was saved in
      if isa(pf,'PoleFigure') && ~isempty(pf.allR) && ...
          isa(pf.allR{1}.frame,'specimenFrame')
        pf.frame = referenceFrame.reintern(pf.allR{1}.frame);
      end
    end
  end
  
end
