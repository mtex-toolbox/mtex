classdef ODF < dynOption
  
  properties    
    components = {};     % the ODF components, e.g., unimodal, fibres,
    weights    = [];     % the weights
  end
  
  properties (Dependent = true)
    CS          % crystal symmetry for ODF
    SS          % specimen symmetry for ODF
    antipodal   % mori =? inv(mori)
    bandwidth   % harmonic degree
  end
  
  methods
    function odf = ODF(components,weights)
      
      if nargin == 0, return;end
          
      odf.components = ensurecell(components);
      if nargin == 2
        odf.weights    = weights;
      else
        odf.weights = 1;
      end      
    end
    
    function odf = set.CS(odf,CS)
      for i = 1:numel(odf.components)
        odf.components{i}.CS = CS;
      end
    end
    
    function CS = get.CS(odf)
      if ~isempty(odf.components)
        CS = odf.components{1}.CS;
      else
        CS = [];
      end      
    end
    
    function odf = set.SS(odf,SS)
      for i = 1:numel(odf.components)
        odf.components{i}.SS = SS;
      end
    end
    
    function SS = get.SS(odf)
      if ~isempty(odf.components)
        SS = odf.components{1}.SS;
      else
        SS = [];
      end      
    end
    
    function odf = set.antipodal(odf,antipodal)
      for i = 1:numel(odf.components)
        odf.components{i}.antipodal = antipodal;
      end
    end
    
    function antipodal = get.antipodal(odf)
      if ~isempty(odf.components)
        antipodal = odf.components{1}.antipodal;
      else
        antipodal = false;
      end      
    end
    
    function L = get.bandwidth(odf)
      L = 0;
      for i = 1:numel(odf.components)
        L = max(L,odf.components{i}.bandwidth);
      end
    end
    
    function odf = set.bandwidth(odf,L)
      for i = 1:numel(odf.components)
        odf.components{i}.bandwidth =L;
      end
    end
    
  end
  
  methods (Static = true)

    [odf,interface,options] = load(fname,varargin)
    
    [odf,resvec] = interp(ori,values,varargin)
    
    function odf = ambiguity1(varargin)

      cs = crystalSymmetry('222');

      orix = orientation.byAxisAngle(xvector,90*degree,cs);
      oriy = orientation.byAxisAngle(yvector,90*degree,cs);
      oriz = orientation.byAxisAngle(zvector,90*degree,cs);

      odf = unimodalODF([orix,oriy,oriz],varargin{:});
    end

    function odf = ambiguity2(varargin)
      cs = crystalSymmetry('222');
      ori = orientation.byAxisAngle(vector3d(1,1,1),[0,120,240]*degree,cs);
      odf = unimodalODF(ori,varargin{:});
    end
    
  end
     
end
