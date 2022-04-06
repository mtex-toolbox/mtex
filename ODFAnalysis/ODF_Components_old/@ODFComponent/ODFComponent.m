classdef ODFComponent
% abstract class representing an ODF component
%
% Description
% This is an abstract class. Subclasses are uniformODF, unimodalODF,
% fibreODF, BinghamODF and FourierODF
%

  properties (Abstract)
    CS % crystal symmetry
    SS % specimen symmetry
    bandwidth % harmonic degree
  end
   
  methods(Abstract)
    f = eval(odf,g,varargin)
    Z = calcPDF(odf,h,r,varargin)    
    odf = rotate(odf,q,varargin)
    f_hat = calcFourier(odf,L,varargin)
    display(odf)
  end
  
end
