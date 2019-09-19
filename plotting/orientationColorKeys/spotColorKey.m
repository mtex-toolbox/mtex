classdef spotColorKey < orientationColorKey
  % 
  %   Detailed explanation goes here
  
  properties
    center
    color
    psi
  end
  
  methods
    function oM = spotColorKey(varargin)
      oM = oM@orientationColorKey(varargin{:});
      
      oM.center = get_option(varargin,'center',orientation.id(oM.CS1));
      oM.CS1 = oM.center.CS;
      oM.color = get_option(varargin,'color',[1 0 0]);
      oM.psi = get_option(varargin,'kernel',...
        deLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',10*degree)));
    end
  
    function rgb = orientation2color(oM,ori)
      
      s = size(ori);
      rgb = ones([s,3]);

      for k=1:length(oM.center)

        w = oM.psi.K(dot(ori,oM.center(k)))./oM.psi.K(1);

        cdata = rgb2hsv(repmat(oM.color(k,:),length(ori),1));
        cdata(:,2) = w(:).*cdata(:,2);
        cdata = reshape(hsv2rgb(cdata),[s,3]);
        rgb = rgb.*cdata;
      end
    end
  end
end
