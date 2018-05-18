classdef TSLDirectionKey < directionColorKey
  % converts directions to rgb values
    
  methods
    
    function dM = TSLDirectionKey(varargin)
      dM@directionColorKey(varargin{:});
      dM.sym = dM.sym.Laue;
      dM.sR = dM.sym.fundamentalSector;
    end
  
    function rgb = direction2color(dM,h,varargin)      
      % in TSL all fundamental sectors are colorized with white in the center
  
      % project to fundamental region
      h_sR = h.project2FundamentalRegion(dM.sym);
      h = h_sR;

      % this should become white if not stated differently
      center = dM.sR.center;

      if ismember(dM.sym.id,[2,18,27,35,42])
        warning('Not a topological correct colormap! Green to blue colorjumps possible');
      end

      % compute angle of the points "sh" relative to the center point "center"
      % this should be between 0 and 1
      [radius,rho] = polarCoordinates(dM.sR,h,center,xvector);

      % white center
      radius = 0.5+radius./2;

      % compute the color vector on the sphere
      v = vector3d('rho',rho,'theta',radius.*pi);

      % post processing of the color vector
      % by default we have white at the z, black at the -z, red
      % at x and green and blue at 120 and 240 degree accordingly
      % post rotate the color
      v = dM.colorPostRotation * v;

      % compute rgb values
      rgb = ar2rgb(mod(v.rho./ 2 ./ pi,1),v.theta./pi,get_option(varargin,'grayValue',1),'noHueCorrection');      
      
    end
  end
  
end
