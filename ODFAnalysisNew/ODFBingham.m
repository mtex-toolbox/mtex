classdef ODFBingham < ODFBase & SO3FunBingham
  
  
  methods
    function odf = ODFBingham(varargin)
      
      odf = odf@SO3FunBingham(varargin{:});
      
    end
  end
  
  
end