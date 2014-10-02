classdef ipdfCenterOrientationMapping < ipdfOrientationMapping
  % 
  %   Detailed explanation goes here
  
  properties
    center
    color
    psi
  end
  
  methods
    function oM = ipdfCenterOrientationMapping(varargin)
      oM = oM@ipdfOrientationMapping(varargin{:});
      
      oM.center = get_option(varargin,'center',Miller(0,0,1,oM.CS1));
      oM.CS1 = oM.center.CS;
      oM.color = get_option(varargin,'color',[1 0 0]);
      oM.psi = get_option(varargin,'kernel',...
        deLaValeePoussinKernel('halfwidth',get_option(varargin,'halfwidth',10*degree)));
    end
  
    function rgb = Miller2color(oM,h)
      
      s = size(h);
      rgb = ones([s,3]);

      for k=1:length(oM.center)

        w = oM.psi.RK(dot(h,oM.center(k))) ./ oM.psi.RK(1);
  
        cdata = rgb2hsv(repmat(oM.color(k,:),length(h),1));
        cdata(:,2) = w(:).*cdata(:,2);
        cdata = reshape(hsv2rgb(cdata),[s,3]);
        rgb = rgb.*cdata;
      end
    end
  end
end
