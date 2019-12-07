classdef ODFRBF < ODFBase & SO3FunRBF
  
  
  methods
    function odf = ODFRBF(varargin)
      
      odf = odf@SO3FunRBF(varargin{:});
      
    end
  end
  
  
end