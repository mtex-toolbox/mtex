classdef ODFHarmonic < ODFBase & SO3FunHarmonic
  
  
  methods
    function odf = ODFHarmonic(varargin)
      
      odf = odf@SO3FunHarmonic(varargin{:});
      
    end
  end
  
  
end