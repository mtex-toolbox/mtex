classdef spotColorKey < orientationColorKey
  % colors a neighbourhood of given orientations and leaves the rest gray
  %
  % Every orientation within the halfwidth of one of the centers takes that
  % center's color, faded by the kernel. Useful for pointing out a handful of
  % texture components in a map without recoloring everything.
  %
  % Syntax
  %   oM = spotColorKey(ori)
  %   oM = spotColorKey(cs,'center',ori,'halfwidth',15*degree)
  %   rgb = oM.orientation2color(ori)
  %
  % Input
  %  cs  - @crystalSymmetry
  %  ori - @orientation
  %
  % Output
  %  oM  - @spotColorKey
  %  rgb - list of RGB triplets
  %
  % Options
  %  center    - the @orientation to be colored
  %  color     - one RGB triplet per center
  %  halfwidth - width of the colored neighbourhood
  %  kernel    - @SO3Kernel used instead of halfwidth
  %
  % Class Properties
  %  center - the colored @orientation
  %  color  - one RGB triplet per center
  %  psi    - the @SO3Kernel defining the fade
  %
  % See also
  % orientationColorKey ipfColorKey EBSDColorCoding
  %
  
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
        SO3DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth',10*degree)));
    end
  
    function [props,propV] = keyRows(oM)
      % how many spots are colored and how wide they are

      props = {'spots'}; propV = {int2str(length(oM.center))};

      if ~isempty(oM.psi)
        props{end+1} = 'halfwidth';
        propV{end+1} = [xnum2str(oM.psi.halfwidth/degree) '°'];
      end

    end

    function rgb = orientation2color(oM,ori)
      
      s = size(ori);
      rgb = ones([s,3]);

      for k=1:length(oM.center)

        w = oM.psi.eval(dot(ori,oM.center(k)))./oM.psi.eval(1);

        cdata = rgb2hsv(repmat(oM.color(k,:),length(ori),1));
        cdata(:,2) = w(:).*cdata(:,2);
        cdata = reshape(hsv2rgb(cdata),[s,3]);
        rgb = rgb.*cdata;
      end
    end
  end
end
