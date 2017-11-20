classdef sphFun
% a class represeneting a function on the sphere
   
  methods

  end    

  
  methods (Abstract = true)
    
    f = eval(sF,v,varargin)
    
  end

	methods (Sealed = true)
		h = plot(sF,varargin)
	end
end
  



