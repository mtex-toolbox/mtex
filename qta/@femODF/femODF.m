classdef femODF < ODF
% define a unimodal ODF
%

  properties
    center % 
    weights %
  end
 
  methods
    
    function odf = femODF(varargin)
      
      % call superclass constructor
      odf = odf@ODF(varargin{:});      
            
      if nargin > 0 && isa(varargin{1},'ODF'), return;end
      
      % get center
      if nargin > 0 && isa(varargin{1},'quaternion')

        odf.center = varargin{1};
        
        if isa(odf.center,'orientation')
          odf.CS = get(odf.center,'CS');
          odf.SS = get(odf.center,'SS');
        else
          odf.center = orientation(odf.center,odf.CS,odf.SS);
        end
      else
        odf.center = orientation(idquaternion,odf.CS,odf.SS);
      end

      % get weights
      odf.weights = get_option(varargin,'weights',ones(size(odf.center)));
      assert(numel(odf.weights) == length(odf.center),...
        'Number of orientations and weights must be equal!');
            
    end
  end
  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    mdf = doMDF(odf1,odf2,varargin)
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin)
    ori = discreteSample(odf,npoints,varargin)
    [v,varargout] = doVolume(odf,center,radius,varargin)
    doDisplay(odf)
  end    
  
end
