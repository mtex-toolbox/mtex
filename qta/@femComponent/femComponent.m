classdef femComponent < ODFComponent
% defines an ODF by finite elements
%

  properties
    center = DelaunaySO3;   % 
    weights = [];           %
  end
  
  properties (Dependent = true)
    CS % crystal symmetry
    SS % specimen symmetry
  end
 
 
  methods
    
    function odf = femODF(varargin)
                      
      if nargin == 0, return;end
      
      % get center
      if nargin > 0 && isa(varargin{1},'quaternion')

        odf.center = varargin{1};
        
        if isa(odf.center,'orientation')
          odf.CS = get(odf.center,'CS');
          odf.SS = get(odf.center,'SS');
        else
          odf.center = orientation(odf.center,odf.CS,odf.SS);
        end
      else
        odf.center = orientation(idquaternion,odf.CS,odf.SS);
      end

      % get weights
      odf.weights = get_option(varargin,'weights',ones(size(odf.center)));
      assert(numel(odf.weights) == length(odf.center),...
        'Number of orientations and weights must be equal!');
            
    end
    
    function component = set.CS(component,CS)
      component.center.CS = CS;
    end
    
    function CS = get.CS(component)
      CS = component.center.CS;      
    end
    
    function component = set.SS(component,SS)
      component.center.SS = SS;
    end
    
    function SS = get.SS(component)
      SS = component.center.SS;
    end
    
  end  
end
