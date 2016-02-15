classdef TSLOrientationMapping < ipdfHSVOrientationMapping
  % orientation mapping as it is used by TSL and HKL software
      
  methods
    function oM =TSLOrientationMapping(varargin)
      oM = oM@ipdfHSVOrientationMapping(varargin{:});
      oM.CS1 = oM.CS1.Laue;
      oM.sR = oM.CS1.fundamentalSector;
      
    end
  end
  
  methods (Access=protected)
    function rgb = h2color(oM,h,varargin)
      % in HKL all fundamental sectors a colorized by white in the center
  
      cs = oM.CS1;

      % region to be colored
      sR = cs.fundamentalSector;

      % project to fundamental region
      h_sR = h.project2FundamentalRegion(cs);
      h = h_sR;

      % this should become white if not stated differently
      center = sR.center;

      rot = rotation(idquaternion);

      if ismember(cs.id,[2,18,27,35,42])
        warning('Not a topological correct colormap! Green to blue colorjumps possible');
      end

      % compute angle of the points "sh" relative to the center point "center"
      % this should be between 0 and 1
      [radius,rho] = polarCoordinates(sR,h,center,xvector);

      % white center
      radius = 0.5+radius./2;

      % compute the color vector on the sphere
      v = vector3d('rho',rho,'theta',radius.*pi);

      % post processing of the color vector
      % by default we have white at the z, black at the -z, red
      % at x and green and blue at 120 and 240 degree accordingly
      % post rotate the color
      v = oM.colorPostRotation * rot * v;

      % compute rgb values
      rgb = ar2rgb(mod(v.rho./ 2 ./ pi,1),v.theta./pi,get_option(varargin,'grayValue',1),'noHueCorrection');

    end

  end
  
end
