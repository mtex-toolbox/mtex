classdef ipdfAngleOM < ipdfOrientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
    
  properties
    convention = 'theta'
  end
  
  methods
    function oM = ipdfAngleOM(varargin)
      oM = oM@ipdfOrientationMapping(varargin{:});
      oM.convention = extract_option(varargin,{'rho','theta','both'});
      if isempty(oM.convention)
        oM.convention = 'theta';
      else
        oM.convention = oM.convention{1};
      end
    end
    
    function c = Miller2color(oM,h)
      % compute minimum angle
      h = h.rmOption('theta');
      h = symmetrise(Miller(h,oM.CS1));

      % convert to polar angles
      [theta,rho] = polar(h(:));

      switch oM.convention
        case 'rho'
          
          c = rho;
    
        case 'theta'
    
          c = theta;
    
        case 'both'
    
          c = (theta + rho);
          
      end

      c = reshape(c,size(h))./degree;
      [~,col] = min(abs(c-min(abs(c(:,1)))));
      c = c(sub2ind(size(c),col,1:size(c,2)));

    end
  end
  
end
