classdef ODFComponent
     
  properties (Abstract)
    CS % crystal symmetry
    SS % specimen symmetry
  end
  
  methods(Abstract)
    f = eval(odf,g,varargin)
    Z = calcPDF(odf,h,r,varargin)    
    odf = rotate(odf,q,varargin)
    f_hat = calcFourier(odf,L,varargin)
    display(odf)
  end
  
end
