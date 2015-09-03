classdef omegaSections < pfSections
     
  methods
    
    function oS = omegaSections(CS1,CS2,h1,h2,r_ref,varargin)
            
      oS = oS@pfSections(CS1,CS2);
     
      if nargin >= 3, oS.h1 = h1;end
      if nargin >= 4, oS.h2 = h2;end
      if nargin < 4, r_ref = xvector; end
      
      oS.maxOmega = 2*pi / CS1.nfold(oS.h1);
      
      % get sections
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'omega',oS.omega,'double');
      
      oS.referenceField = @(r) pfSections.polarField(r,r_ref);
      
    end            
  end  
end
