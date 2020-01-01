classdef sigmaSections < pfSections
     
  methods
    
    function oS = sigmaSections(CS1,CS2,varargin)
            
      oS = oS@pfSections(CS1,CS2);
                
      oS.maxOmega = 2*pi / CS1.nfold(oS.h1);
      
      % get sections
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'sigma',oS.omega,'double');
      
      oS.updateTol(oS.omega);
      
      oS.referenceField = S2VectorField.sigma;
            
    end            
  end  
end
