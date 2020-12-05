classdef HSVDirectionKey < directionColorKey
  % converts crystal or specimen directions to rgb values
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
    colorStretching = 1;
    whiteCenter = vector3d(1,0,0)
    grayValue = [0.2 0.5]
    grayGradient = 0.5 % 0.25
    maxAngle = inf   
  end

  properties %(Access = private)
    refl = [];
    rot = rotation.id;
    alpha = 0;
  end
  
  methods
    
    function dM = HSVDirectionKey(varargin)
            
      dM = dM@directionColorKey(varargin{:});
      if ismember(dM.sym.id,[2,18,26])
        warning(['Not a topological correct colormap! Please use the point group ' char(dM.sym.properGroup)]);
      end
      
      dM.updatesR;
    end

    function rgb = direction2color(dM,h,varargin)
      
      h = vector3d(h);
      h.antipodal = false;
      h = h.project2FundamentalRegion(dM.sym);
      
      wC = vector3d(project2FundamentalRegion(dM.whiteCenter,dM.sym));
      
      if dM.maxAngle < inf
        
        if angle(vector3d.Z,wC) < 1*degree
          owC = orth(wC);
        else
          owC = vector3d.Z;
        end
        
        h = project2FundamentalRegion(h,dM.sym,wC);
        
        rho = angle(h,owC,wC);
        radius = max(0,1 - angle(h,wC) ./ dM.maxAngle);
      
      else
        
        switchWB = false;
      
        % copy to the reduced sector
        h_sR = h;
        whiteOrBlack = true(size(h));
        for i = 1:length(dM.refl)
          ind = dot(h_sR,dM.refl(i)) < 1e-5;
          h_sR(ind) = reflection(dM.refl(i)) * h_sR(ind);
          whiteOrBlack = whiteOrBlack & ~ind;
          
          if dot(wC,dM.refl(i))<1e-5
            wC = reflection(dM.refl(i)) * wC;
            switchWB = ~switchWB;
          end
        end
      
        % which are white
        whiteOrBlack = xor(whiteOrBlack,switchWB);
      
        % compute angle of the points "sh" relative to the center point "center"
        % this should be between 0 and 1
        if isa(dM.sym,'crystalSymmetry')
          ref = vector3d(dM.sym.aAxisRec);
        else
          ref = xvector;
        end
        [radius,rho] = polarCoordinates(dM.sR,h_sR,wC,ref,'maxAngle',dM.maxAngle);
              
        % white center
        radius(whiteOrBlack) = 0.5+radius(whiteOrBlack)./2;
        
        % black center
        radius(~whiteOrBlack) = (1-radius(~whiteOrBlack))./2;

      end
      
      % stretch colors
      radius = radius*(1+dM.alpha)-dM.alpha;
      
      % compute the color vector on the sphere
      v = vector3d('rho',rho,'theta',radius.*pi);

      % post processing of the color vector
      % by default we have white at the z, black at the -z, red
      % at x and green and blue at 120 and 240 degree accordingly
      % post rotate the color
      v = dM.colorPostRotation * dM.rot * v;
      [th,rh] = polar(v);
      
      % stretching of the colors
      %th = (th ./ pi) .* pi;

      % correct white -> color gradient
      ind = th > pi/2;
      
      % the white region
      th(ind) = ((2 * dM.grayGradient(1) * th(ind) ./pi + ...
        (1 - dM.grayGradient(1)) * (1-cos(th(ind)))) ./ 2) .^ dM.colorStretching;
      
      % the black region
      th(~ind) = ((2 * dM.grayGradient(end) * th(~ind) ./pi + ...
        (1 - dM.grayGradient(end)) * (1-cos(th(~ind)))) ./ 2) .^ dM.colorStretching;
      
      gray = th;
      gray(ind) = 1 - 2*dM.grayValue(1)*abs(gray(ind) - 0.5);
      gray(~ind) = 1 - 2*dM.grayValue(end)*abs(gray(~ind) - 0.5);
      
      gray = get_option(varargin,'grayValue',gray);
      
      % compute rgb values
      rgb = ar2rgb(mod(rh./ 2 ./ pi,1),th,gray);

      rgb(isnan(h.x),:) = NaN;
      
      %rgb = rgb2gray(rgb);
      
    end
    
    
  end
  
  methods (Access=protected)
                
    function updatesR(oM)
      % spherical region to be colorized

      oM.sR = oM.sym.fundamentalSector;
      r30 = rotation.byAxisAngle(zvector,[30,-30]*degree);

      % symmetry dependent settings
      switch oM.sym.id
        case 0
          sR = oM.sym.Laue.fundamentalSector;
          oM.refl = setdiff(sR.N,oM.sR.N);
        case 1                                                   % 1
          if isa(oM.sym,'crystalSymmetry')                     
            oM.refl = oM.sym.rot.axis;
          else
            oM.refl = vector3d.Z;
          end
        case {3,9}                                               % 211, 112  
          oM.refl = -rotate(oM.sR.N,rotation.byAxisAngle(oM.sym.rot(2).axis,90*degree));
        case 6                                                   % 121
          oM.refl = rotate(oM.sR.N,rotation.byAxisAngle(-oM.sym.rot(2).axis,90*degree));
        case {5}, oM.refl = rotate(oM.sR.N(2),-90*degree);       % 2/m11
        case {8}, oM.refl = rotate(oM.sR.N(2),90*degree); %      % 12/m1
        case {11,12}, oM.refl = rotate(oM.sR.N(2),-90*degree); % 222
        case 17, oM.refl = -rotate(sum(oM.sR.N),90*degree);      % 3        
        case 18, oM.refl = -rotate(sum(oM.sR.N(2:3)),90*degree); % -3
        case 19
          oM.refl = r30 .* oM.sR.N(end-1:end);                   % 321
          if angle(oM.refl(1),oM.refl(2)) < 1*degree
            oM.refl = inv(r30) .* oM.sR.N(end-1:end);
          end
        case 21, oM.refl =  rotate(sum(oM.sR.N(2:3)),90*degree);    % -31m, -3m1
        case 22, oM.refl =  -rotate(sum(oM.sR.N(2:3)),90*degree);   % 312
        case 24, oM.refl =  -rotate(sum(oM.sR.N(2:3)),90*degree);   % -31m, -3m1
        case {25,27,28}, oM.refl = rotate(oM.sR.N(end),-45*degree); % 4,4/m,422
        case 26, oM.refl = rotate(oM.sR.N(end),-90*degree);      % -4
        case 30, oM.refl = rotate(oM.sR.N(2),45*degree);            % -42m
        case 31, oM.refl = -rotate(oM.sR.N(2),45*degree);        % -4m2
        case {33,35,36}, oM.refl = rotate(oM.sR.N(end),-30*degree); % 6,6/m, 622,  
        case 34, oM.refl = rotate(oM.sR.N(end),-60*degree);            % -6
        case {41}, oM.refl = sum(oM.sR.N(3:4))- sum(oM.sR.N(1:2));  % 23
        case {42,43}, oM.refl = oM.sR.N(end-2) - oM.sR.N(end-1);      % 432, m-3  
      end
      
      % reduce fundamental sector by reflectors for black-white colorcoding
      oM.sR.N = [oM.sR.N(:);oM.refl(:)];
      oM.sR.alpha = [oM.sR.alpha(:);zeros(length(oM.refl),1)];
      oM.whiteCenter = oM.sR.center;
      
    end    
  end
  
  methods (Static = true)
   function rot = green2white % rotate green 2 white
      rot = rotation.byAxisAngle(xvector,90*degree); 
    end

    function rot = blue2green % switch blue and green
      rot = reflection(yvector); 
    end

    function rot = black2white % switch white and black
      rot = reflection(zvector);
    end
  end
end
