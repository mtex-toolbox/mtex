classdef uniformODF < ODF
    
  methods
    function odf = uniformODF(cs,ss,varargin)
      
      odf.CS = cs;
      odf.SS = ss;
    end
  end
  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    odf = doRotate(odf,~,varargin)
    f_hat = doFourier(odf,L,varargin)
    ori = discreteSample(odf,npoints,varargin)
    [v,varargout] = doVolume(odf,center,radius,varargin)
    doDisplay(odf)    
  end    
  
end
