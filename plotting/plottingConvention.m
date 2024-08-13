classdef plottingConvention < matlab.mixin.Copyable
% class describing the alignment of a reference frame on the screen
%
% Syntax
%   % specify a custom plotting convention
%   pC = plottingConvention(outOfScreen,east)
%   plot(ebsd,pC)
%
%   % changing the default plotting convention
%   plottingConvention.default.east = yvector
%
%   % changing the plotting convention for a dataset
%   % to be used in all future plotting commands
%   ebsd.plottingConvention = pC
%
% Input
%  outOfScreen - @vector3d 
%  east        - @vector3d
%
% Output
%  pC - @plottingConvention
  
  properties
    rot = rotation.id % screen coordinates to reference coordinates
  end
  
  properties (Dependent=true)
    east   % axis that point east (default = x)
    west   % axis that point west (default = -x)
    north  % axis that point north (default = y)
    south  % axis that point south (default = -y)
    outOfScreen % axis that point out of screen (default = z)
    intoScreen  % axis that point into screen (default = -z)
    viewOpt  % translates screen orientation in MATLAB options
  end

  methods

    function pC = plottingConvention(outOfScreen,east)
      
      if nargin >= 1, pC.outOfScreen = outOfScreen; end
      if nargin >= 2, pC.east = east; end

    end
        
    function display(pC,varargin)
      displayClass(pC,inputname(1),varargin{:});
    
      if ~check_option(varargin,'skipHeader'), disp(' '); end

      props{1} = 'outOfScreen';
      propV{1} = ['(' char(round(pC.outOfScreen)) ')'];

      props{2} = 'north';
      propV{2} = ['(' char(round(pC.north)) ')'];

      props{3} = 'east';
      propV{3} = ['(' char(round(pC.east)) ')'];
      
      % display all properties
      cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

      disp(' ')

    end

    function setView(pC,ax)

      if nargin == 1, ax = gca; end

      if isgraphics(ax,'axes') && isappdata(ax,'sphericalPlot')

        sP = getappdata(ax,'sphericalPlot');
       
        sP.updateBounds;

        warning('Can not change plotting convention in sphercical projections after plotting!');

      elseif isa(ax,'matlab.graphics.axis.PolarAxes')
        
        switch round(angle(pC.east,xvector,zvector)/degree)
          case 0
            ax.ThetaZeroLocation='right';
          case 90
            ax.ThetaZeroLocation='top';
          case 180
            ax.ThetaZeroLocation='left';
          case 270
            ax.ThetaZeroLocation='bottom';
        end
        if pC.outOfScreen.z<0
          ax.ThetaDir='clockwise';
        else
          ax.ThetaDir='counterclockwise';
        end

      elseif ax.PlotBoxAspectRatioMode == "manual" % 3d plot
        
        %cameraDist = norm(ax.CameraPosition - ax.CameraTarget);
        %ax.CameraPosition = ax.CameraTarget + cameraDist*pC.outOfScreen.xyz;
        %ax.CameraUpVector = pC.north.xyz;
        
        ax.CameraUpVector = pC.north.xyz;
        view(ax,pC.outOfScreen.xyz);
        

      else % map plot

        %ax.CameraPosition = ax.CameraTarget + 1000*pC.outOfScreen.xyz;

        ax.CameraUpVector = pC.north.xyz;
        view(ax,pC.outOfScreen.xyz);
        

      end
      
    end

    function opt = get.viewOpt(pC)
      opt = {'CameraPosition',1000*pC.outOfScreen.xyz,...
        "CameraUpVector",pC.north.xyz};
    end


    function v = get.outOfScreen(pC), v = pC.rot * vector3d.Z; end
    function set.outOfScreen(pC,n)
      try
        pC.rot = rotation.map(pC.outOfScreen,n,pC.east,pC.east) * pC.rot;
      catch
        pC.rot = rotation.map(pC.outOfScreen,n) * pC.rot;
      end
    end

    function v = get.intoScreen(pC), v = -pC.rot * vector3d.Z; end
    function set.intoScreen(pC,n)
      try
        pC.rot = rotation.map(pC.outOfScreen,-n,pC.east,pC.east) * pC.rot;
      catch
        pC.rot = rotation.map(pC.outOfScreen,-n) * pC.rot;
      end
    end


    function v = get.east(pC), v = pC.rot * vector3d.X; end
    function set.east(pC,e)
      try
        pC.rot = rotation.map(pC.east,e,pC.outOfScreen,pC.outOfScreen) * pC.rot; 
      catch ME
        pC.rot = rotation.map(pC.east,e) * pC.rot;
      end
    end

    function v = get.west(pC), v = -pC.rot * vector3d.X; end
    function set.west(pC,w)
      try
        pC.rot = rotation.map(pC.east,-w,pC.outOfScreen,pC.outOfScreen) * pC.rot; 
      catch
        pC.rot = rotation.map(pC.east,-w) * pC.rot; 
      end
    end

    function v = get.north(pC), v = pC.rot * vector3d.Y; end
    function set.north(pC,v)
      try
        pC.rot = rotation.map(pC.north,v,pC.outOfScreen,pC.outOfScreen) * pC.rot; 
      catch
        pC.rot = rotation.map(pC.north,v) * pC.rot; 
      end
    end
    
    function v = get.south(pC), v = -pC.rot * vector3d.Y; end
    function set.south(pC,v)
      try
        pC.rot = rotation.map(pC.north,-v,pC.outOfScreen,pC.outOfScreen) * pC.rot;
      catch ME
        pC.rot = rotation.map(pC.north,-v) * pC.rot;
      end      
    end

    function plot(pC, varargin)

      ax = get_option(varargin,'parent',gca);

      delta(1) = diff(ax.XLim);
      delta(2) = diff(ax.YLim);
      delta(3) = diff(ax.ZLim);
      delta = get_option(varargin,'delta',median(delta)/20);

      
      ref = vector3d(700,60,0);

      frame = get_option(varargin,'frame',vector3d.byXYZ(eye(3)));
      frame = delta * frame.normalize;

      labels = get_option(varargin,'labels',{'X','Y','Z'});

      hold on
      for k = 1:length(frame)
        
        u = frame(k);
        if abs(dot(pC.outOfScreen,u))>delta*(1-1e-3), continue; end
        
        optiondraw(quiver3(ref.x,ref.y,ref.z,u.x,u.y,u.z,0,...
          "filled",'LineWidth',1.5,'ShowArrowHead','on','Color','black','MaxHeadSize',3),varargin{:});

        tpos = ref + 1.3*u;
        text(tpos.x,tpos.y,tpos.z,labels{k},'FontSize',getMTEXpref('FontSize'))
      end
      hold off

    end

  end

  methods (Static=true)
  
    function test
      grainsR = rotate(grains,rotation.rand);
      plot(grainsR,grainsR.meanOrientation,'micronbar','off');
      pC.outOfScreen = grainsR.N; pC.setView(gca)
    end

    function pC = default
      pC = getMTEXpref('xyzPlotting');
    end

  end

end

