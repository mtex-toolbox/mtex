classdef ipdfCenterOrientationMapping < ipdfOrientationMapping
  % 
  % Maps an individual color to each given crystal directions being 
  % parallel to a specimen direction (fibre)
  % Properties:
  % center  - List of crystal directions @Miller
  % color   - n-by-3 list representing RGB values, one for each center
  % psi     - @kernel providing the width and brightness for colored fibre
  % inversePoleFigureDirection - specimen direction @vector3d
  
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
      rgb = ones(length(h),3);

      for k=1:length(oM.center)

        w = oM.psi.RK(dot(h,oM.center(k))) ./ oM.psi.RK(1);
  
        cdata = rgb2hsv(repmat(oM.color(k,:),length(h),1));
        cdata(:,2) = w(:).*cdata(:,2);
        cdata = reshape(hsv2rgb(cdata),[],3);
        rgb = rgb.*cdata;
      end
    end
  end
end
