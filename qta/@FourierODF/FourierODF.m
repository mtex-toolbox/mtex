classdef FourierODF < ODF
  % defines an ODF by its Fourier coefficients
  %
  % Description
  % *FourierODF* defines an  ODF by its Fourier coefficients
  %
  % Syntax
  %   odf = FourierODF(C,CS,SS)
  %
  % Input
  %  C      - Fourier coefficients / C -- coefficients
  %  CS, SS - crystal, specimen @symmetry
  %
  % Output
  %  odf - @ODF
  %
  % See also
  % ODF/ODF uniformODF fibreODF unimodalODF
  
  properties
    f_hat    
  end
 
  methods
    
    function odf = FourierODF(varargin)
          
      % call superclass constructor
      odf = odf@ODF(varargin{:});      
        
      % compute FourierODF from another ODF
      if nargin >= 1 && isa(varargin{1},'ODF')
              
        odf.f_hat = calcFourier(varargin{:});
        odf.weight = odf.f_hat(1);
        odf.f_hat = odf.f_hat ./ odf.weight;
        
        return
        
      end

      % extract f_hat
      C = varargin{1};
      if isa(C,'cell')
        odf.f_hat = [];
        for l = 0:numel(C)-1
          odf.f_hat = [odf.f_hat;C{l+1}(:) * sqrt(2*l+1)];
        end
      else
        odf.f_hat = C;
      end
    end
  end

  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    mdf = doMDF(odf1,odf2,varargin)
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin);
    [TVoigt, TReuss] = doMeanTensor(odf,T,varargin)
    doDisplay(odf)
  end    
  
end
