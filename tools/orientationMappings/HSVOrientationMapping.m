classdef HSVOrientationMapping < orientationMapping
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  % converts crystal directions to rgb values
  %
  % The priciple idea is to take the fundamental sector, apply white to the
  % center and red, blue and green to the vertices. This works well if all
  % the edges of the fundamental sector are reflections, i.e. for for m, mm2,
  % mmm, 3m, 4mm, 4/mmm, 6mm, -62m, 6/mmm, -43m, m-3m.
  % In almost all other cases the fundamental sector can be divided by an
  % additional reflection into two subsectors which are colored one with
  % white and one with black center.
  % There are three cases, -1, -3, -4, where this does not work. Actually one
  % can show that in this cases it is impossible to have a smooth one to one
  % relation between the color space and the fundamental sector.
  
  properties
    colorPostRotation = rotation(idquaternion)
    colorStretching = 1;
    whiteCenter = vector3d(1,0,0)
    grayValue = [0.2 0.5]
    grayGradient = 0.5 % 0.25
    maxAngle = inf
    sR = sphericalRegion    
  end

  properties %(Access = private)
    refl = [];
    rot = rotation(idquaternion);
    alpha = 0;
  end
  
  methods
    
    function oM = HSVOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
      
      if ismember(oM.CS1.id,[2,18,26])
        warning(['Not a topological correct colormap! Please use the point group ' oM.CS1.char]);
      end
      
      oM.updatesR;
    end

  end
  
  methods (Access=protected)
                
    function updatesR(oM)
      % spherical region to be colorized

      cs = oM.CS1;
      oM.sR = cs.fundamentalSector;
      r30 = rotation('axis',zvector,'angle',[30,-30]*degree);

      % symmetry dependent settings
      switch cs.id
        case 1, oM.refl = cs.axes(3);                            % 1
        case {3,9}                                               % 211, 112  
          oM.refl = -rotate(oM.sR.N,rotation('axis',cs.subSet(2).axis,'angle',90*degree));
        case 6,                                                  % 121
          oM.refl = rotate(oM.sR.N,rotation('axis',cs.subSet(2).axis,'angle',90*degree));
        case {5}, oM.refl = rotate(oM.sR.N(2),90*degree);   % 222
        case {8,11,12}, oM.refl = rotate(oM.sR.N(2),-90*degree); % 222
        case 17, oM.refl = -rotate(sum(oM.sR.N),90*degree);      % 3        
        case 18, oM.refl = -rotate(sum(oM.sR.N(2:3)),90*degree); % -3
        case 19
          oM.refl = r30 .* oM.sR.N(end-1:end);                   % 321
          if angle(oM.refl(1),oM.refl(2)) < 1*degree
            oM.refl = inv(r30) .* oM.sR.N(end-1:end);
          end
        case 21, oM.refl =  rotate(sum(oM.sR.N(2:3)),90*degree); % -31m, -3m1
        case 22, oM.refl =  -rotate(sum(oM.sR.N(2:3)),90*degree); % 312
        case 24, oM.refl =  -rotate(sum(oM.sR.N(2:3)),90*degree); % -31m, -3m1
        case {25,27,28}, oM.refl = rotate(oM.sR.N(end),-45*degree); % 4,4/m,422
        case 26, oM.refl = rotate(oM.sR.N(end),-90*degree);      % -4
        case 30, oM.refl = yvector;                              % -42m
        case 31, oM.refl = -rotate(oM.sR.N(2),45*degree);        % -4m2
        case {33,35,36}, oM.refl = rotate(oM.sR.N(end),-30*degree); % 6,6/m, 622,  
        case 34, oM.refl = rotate(oM.sR.N(end),-60*degree);            % -6
        case {41}, oM.refl = vector3d(-1,0,1);                % 23, 432
        case {42,43}, oM.refl = vector3d(1,-1,0);                     % m-3  
      end
      
      % reduce fundamental sector by reflectors for black-white colorcoding
      oM.sR.N = [oM.sR.N(:);oM.refl(:)];
      oM.sR.alpha = [oM.sR.alpha(:);zeros(length(oM.refl),1)];
      oM.whiteCenter = oM.sR.center;
      
    end
       
    function rgb = h2color(oM,h,varargin)
      
      h.antipodal = false;
      h = h.project2FundamentalRegion(oM.CS1);
      wC = oM.whiteCenter.project2FundamentalRegion(oM.CS1); %#ok<*PROP>
      switchWB = false;
      
      % copy to the reduced sector
      h_sR = h;
      for i = 1:length(oM.refl)
        ind = dot(vector3d(h_sR),oM.refl(i))<1e-5;
        h_sR(ind) = reflection(oM.refl(i)) * h_sR(ind);
        
        if dot(wC,oM.refl(i))<1e-5
          wC = reflection(oM.refl(i)) * wC;
          switchWB = ~switchWB;
        end
      end
        
      % which are white
      whiteOrBlack = xor(h_sR == h,switchWB);
      
      % compute angle of the points "sh" relative to the center point "center"
      % this should be between 0 and 1
      ref = -vector3d(oM.CS1.bAxisRec);
      [radius,rho] = polarCoordinates(oM.sR,h_sR,wC,ref,'maxAngle',oM.maxAngle);

      if oM.maxAngle < inf
        radius = max(0,1 - angle(h_sR(:),wC) ./ oM.maxAngle);
        
        % black center
        radius(~whiteOrBlack) = 0;
      else
              
        % white center
        radius(whiteOrBlack) = 0.5+radius(whiteOrBlack)./2;
        
        % black center
        radius(~whiteOrBlack) = (1-radius(~whiteOrBlack))./2;

      end
      
      % stretch colors
      radius = radius*(1+oM.alpha)-oM.alpha;
      
      % compute the color vector on the sphere
      v = vector3d('rho',rho,'theta',radius.*pi);

      % post processing of the color vector
      % by default we have white at the z, black at the -z, red
      % at x and green and blue at 120 and 240 degree accordingly
      % post rotate the color
      v = oM.colorPostRotation * oM.rot * v;
      [th,rh] = polar(v);
      
      % stretching of the colors
      %th = (th ./ pi) .* pi;

      % correct white -> color gradient
      ind = th > pi/2;
      
      % the white region
      th(ind) = ((2 * oM.grayGradient(1) * th(ind) ./pi + ...
        (1 - oM.grayGradient(1)) * (1-cos(th(ind)))) ./ 2) .^ oM.colorStretching;
      
      % the black region
      th(~ind) = ((2 * oM.grayGradient(end) * th(~ind) ./pi + ...
        (1 - oM.grayGradient(end)) * (1-cos(th(~ind)))) ./ 2) .^ oM.colorStretching;
      
      gray = th;
      gray(ind) = 1 - 2*oM.grayValue(1)*abs(gray(ind) - 0.5);
      gray(~ind) = 1 - 2*oM.grayValue(end)*abs(gray(~ind) - 0.5);
      
      gray = get_option(varargin,'grayValue',gray);
      
      % compute rgb values
      rgb = ar2rgb(mod(rh./ 2 ./ pi,1),th,gray);

      rgb(isnan(h.x),:) = NaN;
      
      %rgb = rgb2gray(rgb);
      
    end
  end
  
  methods (Static = true)
   function rot = green2white % rotate green 2 white
      rot = rotation('axis',xvector,'angle',90*degree); 
    end

    function rot = blue2green % switch blue and green
      rot = reflection(yvector); 
    end

    function rot = black2white % switch white and black
      rot = reflection(zvector);
    end
  end
end
