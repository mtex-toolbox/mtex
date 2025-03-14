classdef sphericalProjection
  %sphericalProjection
  
  properties    
    sR = sphericalRegion
    pC = plottingConvention
  end

  properties (Dependent = true)
    antipodal
  end
    
  methods
    
    
    function sP = sphericalProjection(sR,pC)
      
      if nargin > 0, sP.sR = sR; end
      if nargin > 1, sP.pC = pC; end

    end
    
    function [rho,theta] = project(sP,v,varargin)
      % compute polar angles
      
      % map such that projection is towards xy plane
      % and compute there spherical coordinates
      v(~sP.sR.checkInside(v,varargin{:})) = NaN;
      v = v.rmOption('theta','rho');
      [theta,rho] = polar(inv(sP.pC.rot) * v); %#ok<MINV,POLAR>
      
      % map to upper hemisphere
      ind = theta > pi/2+10^(-10);
      theta(ind)  = pi - theta(ind);

      % turn around antipodal vectors
      sP.sR.antipodal = false; v.antipodal = false;
      ind = ~sP.sR.checkInside(v);
      rho(ind) = rho(ind) + pi;

    end
    
    function a = get.antipodal(sP)
      a = sP.sR.antipodal;
    end
    
    function sP = set.antipodal(sP,a)
      sP.sR.antipodal = a;
    end
    
    function out = isUpper(sP)
      out = sP.sR.isUpper(sP.pC);
    end

    function out = isLower(sP)
      out = sP.sR.isLower(sP.pC);
    end

    function S2G = makeGrid(sP, varargin)
      
      % get resolution
      res = get_option(varargin,'resolution',1*degree);

      for iP = 1:length(sP)

        % rotate the spherical region
        sR = inv(sP(iP).pC.rot) * sP(iP).sR; %#ok<MINV,*PROPLC>

        [rhoMin,rhoMax] = rhoRange(sR);
        rho = linspace(rhoMin(1),rhoMax(1),round(1+(rhoMax(1)-rhoMin(1))/res));
        for i = 2:length(rhoMin)
          rho = [rho,nan,linspace(rhoMin(i),rhoMax(i),round(1+(rhoMax(i)-rhoMin(i))/res))]; %#ok<AGROW>
        end

        [thetaMin,thetaMax] = thetaRange(sR,rho);

        % remove values out of region
        ind = (thetaMax > 1e-5) & (thetaMin < pi - 1e-5);
        
        ind(end) = ind(end-1); ind(1) = ind(2);
        
        % we should put some nans to seperate regions
        rho(diff(ind) == 1) = nan;
        ind(diff(ind) == 1) = true;

        rho(~ind) = []; thetaMin(~ind) = []; thetaMax(~ind) = [];

        if isempty(rho)
          v = vector3d;
        else % generate grid

          dtheta = thetaMax - thetaMin;

          % ensure an odd number of points to have some points at the equator
          ntheta = max(3,2*round(max(dtheta./res./2))+1);

          theta = linspace(0,1,ntheta).' * dtheta + repmat(thetaMin,ntheta,1);

          rho = repmat(rho,ntheta,1);

          v = vector3d.byPolar(theta,rho);
        end

        v = v.setOption('plot',true,'resolution',res,'region',sP(iP).sR);
        % the above procedure does not work so well if we have a full sphere
        % and the theta region is not connected
        % thatswhy we have to check once again
        v(~sR.checkInside(v)) = nan;

        S2G{iP} = sP(iP).pC.rot .* v; %#ok<AGROW>
      end
    end

  end
    
end
