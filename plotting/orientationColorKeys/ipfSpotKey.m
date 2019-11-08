classdef ipfSpotKey < ipfColorKey
%  
% Colorizes single spots in the inverse pole figure with individual colors.
%
% Syntax
%   ipfKey = ipfSpotKey
%   ipfKey.inversePoleFigureDirection = zvector; 
%   ipfKey.center = Miller(1,0,0,cs); % the centers of the spots in the inverse pole figure
%   ipfKey.color = [0 0 1];           % the color of the spots
%   ipfKey.psi = S2DeLaValleePoussin('halfwidth',7.5*degree);
%
%   color = ipfKey.orientation2color(ori)
%
% Class Properties
%  center  - list of crystal directions @Miller
%  color   - n-by-3 list representing RGB values, one for each center
%  psi     - @S2Kernel providing the width and brightness for colored fibre
%  inversePoleFigureDirection - specimen direction @vector3d
%
% See also
% EBSDAdvancedMapping
  
  properties
    center % list of crystal directions @Miller
    color  % list of RGB values, one for each center
    psi    % @2Kernel providing the width and brightness for colored fibre 
  end
  
  methods
    function oM = ipfSpotKey(varargin)
      oM = oM@ipfColorKey(varargin{:});
      
      oM.center = get_option(varargin,'center',Miller(0,0,1,oM.CS1));
      oM.CS1 = oM.center.CS;
      oM.color = get_option(varargin,'color',[1 0 0]);
      oM.psi = get_option(varargin,'S2Kernel',...
        S2DeLaValleePoussin('halfwidth',get_option(varargin,'halfwidth',10*degree)));
      
      oM.dirMap = directionColorKey(oM.CS1,'dir2color',@(varargin) oM.dir2color(varargin{:}));
            
    end
  
    function rgb = dir2color(oM,h)
      
      h = normalize(h);
      rgb = ones(length(h),3);

      for k=1:length(oM.center)

        w = oM.psi.eval(dot(h,normalize(oM.center(k)))) ./ oM.psi.eval(1);
  
        if ~any(oM.color(k,:))% fix in case of black
          cdata = repmat([0 1 1],length(h),1);
          cdata(:,2) = w(:).*cdata(:,2);
          cdata = reshape(hsv2rgb(cdata),[],3);
          cdata(:,1)=cdata(:,2);
          rgb = rgb.*cdata;
        else 
          cdata = rgb2hsv(repmat(oM.color(k,:),length(h),1));
          cdata(:,2) = w(:).*cdata(:,2);
          cdata(:,3) = 1;
          cdata = reshape(hsv2rgb(cdata),[],3);
          rgb = rgb.*cdata;
        end
      end
    end
  end
end
