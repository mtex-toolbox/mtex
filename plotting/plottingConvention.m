classdef plottingConvention < matlab.mixin.Copyable
% class describing the alignment of a reference frame on the screen
%
% Syntax
%   % specify a custom plotting convention
%   pC = plottingConvention(outOfScreen,east)
%   plot(ebsd,pC)
%
%   % changing the default plotting convention - note that the default has
%   % to be modified in place, plottingConvention.default.east = yvector
%   % would replace it and detach all data that refers to it
%   pC = plottingConvention.default; pC.east = yvector;
%
%   % changing the plotting convention for a dataset
%   % to be used in all future plotting commands
%   ebsd.how2plot = pC
%
% Input
%  outOfScreen - @vector3d 
%  east        - @vector3d
%
% Output
%  pC - @plottingConvention
%
  
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

  properties (Hidden=true)
    lastSet = []
  end

  methods

    function pC = plottingConvention(outOfScreen,east)

      if nargin == 1
        pC.rot = rotation.map(zvector,outOfScreen);
      elseif nargin == 2
        pC.rot = rotation.map(zvector,outOfScreen,xvector,east);
      end

      %if nargin >= 1, pC.outOfScreen = outOfScreen; end
      %if nargin >= 2, pC.east = east; end      
    end
        
    function display(pC,varargin)
      displayClass(pC,inputname(1),'moreInfo',char(pC,'compact'),varargin{:});
    
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

    function c = char(pC,varargin)

      arrows = '←→↑↓'; xyz = 'xyz';

      [ud,north] = find(pC.north == [1;-1] .* [xvector,yvector,zvector]); %#ok<PROPLC>
      c = [xyz(north) arrows(ud+2)]; %#ok<PROPLC>

      
      [lr,east] = find(pC.east == [1;-1] .* [xvector,yvector,zvector]); %#ok<PROPLC>

      if isempty(ud) || isempty(lr)
        c = 'xyz';
      elseif lr == 1
        c = [c,arrows(2),xyz(east)]; %#ok<PROPLC>
      else
        c = [xyz(east),arrows(1),fliplr(c)]; %#ok<PROPLC>
      end

    end

    function setView(pC,ax)

      if nargin == 1, ax = gca; end

      if isgraphics(ax,'axes') && isappdata(ax,'sphericalPlot')

        sP = getappdata(ax,'sphericalPlot');
       
        sP.updateBounds;

        warning('Can not change plotting convention in spherical projections after plotting!');

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

      elseif ax.PlotBoxAspectRatioMode == "manual" && ...
          ax.CameraPositionMode == "manual" % 3d plot with a placed camera

        % Note: this branch is only for axes whose camera has already been
        % placed by hand (e.g. after rotate3d / zoom in a 3d plot), where the
        % camera distance encodes the current zoom and has to be preserved.
        % Setting CameraPosition/CameraTarget makes them 'manual', which
        % makes MATLAB report ax.TightInset as [0 0 0 0] - the axes then
        % looks like it needs no space for labels and mtexFigure crops them
        % away. For an untouched camera the map branch below is used instead,
        % which leaves the camera modes on 'auto' and keeps TightInset alive.

        %cameraDist = norm(ax.CameraPosition - ax.CameraTarget);
        %ax.CameraPosition = ax.CameraTarget + cameraDist*pC.outOfScreen.xyz;
        %ax.CameraUpVector = pC.north.xyz;

        target = mean([ax.XLim; ax.YLim; ax.ZLim],2).';   % or your own target
        d = norm(ax.CameraPosition - ax.CameraTarget);    % preserve current distance

        guard = plottingConvention.beginCameraUpdate(ax); %#ok<NASGU>

        ax.CameraTarget = target;
        ax.CameraPosition = target + d * pC.outOfScreen.xyz;
        ax.CameraUpVector = pC.north.xyz;
        ax.CameraViewAngleMode = 'auto';   % usually faster and visually stable


        %ax.CameraUpVector = pC.north.xyz;
        %view(ax,pC.outOfScreen.xyz);
        %ax.CameraUpVector = pC.north.xyz;
        %ax.CameraViewAngleMode = 'auto';
      
      else % map plot

        % nothing to do if the camera already matches - this avoids firing
        % the camera PostSet listeners (e.g. the scale bar's) for a no-op
        % view change
        try
          if angle(plottingConvention.getView(ax).rot, pC.rot) < 1e-6
            return
          end
        catch
        end

        %ax.CameraPosition = ax.CameraTarget + 1000*pC.outOfScreen.xyz;

        guard = plottingConvention.beginCameraUpdate(ax); %#ok<NASGU>

        ax.CameraUpVector = pC.north.xyz;
        view(ax,pC.outOfScreen.xyz);
        ax.CameraUpVector = pC.north.xyz;
        ax.CameraViewAngleMode = 'auto';
      end
      
    end

    function opt = get.viewOpt(pC)
      opt = {'CameraPosition',1000*pC.outOfScreen.xyz,...
        "CameraUpVector",pC.north.xyz};
    end


    function v = get.outOfScreen(pC)
      v = pC.rot * vector3d.Z; 
      v.how2plot = pC;
    end

    function set.outOfScreen(pC,n)
      if angle(pC.rot * vector3d.Z,n) > 0.1*degree
        try
          pC.rot = rotation.map(pC.outOfScreen,n,pC.lastSet,pC.lastSet) * pC.rot;
        catch
          pC.rot = rotation.map(pC.outOfScreen,n) * pC.rot;
        end
      end
      pC.lastSet = n;
    end

    function v = get.intoScreen(pC)
      v = -pC.rot * vector3d.Z;
      v.how2plot = pC;
    end
    function set.intoScreen(pC,n)
      try
        pC.rot = rotation.map(pC.outOfScreen,-n,pC.lastSet,pC.lastSet) * pC.rot;
      catch
        pC.rot = rotation.map(pC.outOfScreen,-n) * pC.rot;
      end
      pC.lastSet = n;
    end


    function v = get.east(pC) 
      v = pC.rot * vector3d.X;
      v.how2plot = pC;
    end
    function set.east(pC,e)
      if angle(pC.rot * vector3d.X,e) > 0.1*degree
        try
          pC.rot = rotation.map(pC.east,e,pC.lastSet,pC.lastSet) * pC.rot;
        catch ME
          pC.rot = rotation.map(pC.east,e) * pC.rot;
        end
      end
      pC.lastSet = e;
    end

    function v = get.west(pC)
      v = -pC.rot * vector3d.X; 
      v.how2plot = pC;
    end
    function set.west(pC,w)
      try
        pC.rot = rotation.map(pC.east,-w,pC.lastSet,pC.lastSet) * pC.rot; 
      catch
        pC.rot = rotation.map(pC.east,-w) * pC.rot; 
      end
      pC.lastSet = w;
    end

    function v = get.north(pC)
      v = pC.rot * vector3d.Y(pC); 
      %v.how2plot = pC;
    end
    function set.north(pC,v)
      try
        pC.rot = rotation.map(pC.north,v,pC.lastSet,pC.lastSet) * pC.rot; 
      catch
        pC.rot = rotation.map(pC.north,v) * pC.rot; 
      end
      pC.lastSet = v;
    end
    
    function v = get.south(pC), v = -pC.rot * vector3d.Y; end

    function set.south(pC,v)
      try
        pC.rot = rotation.map(pC.north,-v,pC.lastSet,pC.lastSet) * pC.rot;
      catch ME
        pC.rot = rotation.map(pC.north,-v) * pC.rot;
      end
      pC.lastSet = v;
    end

    function makeDefault(pC)
      plottingConvention.default(pC);
    end

    function out = isapprox(pC,pC2,tol)
      % do two conventions describe the same alignment?

      if nargin < 3, tol = 1e-6; end

      out = isa(pC2,'plottingConvention') && ...
        all(angle(pC.rot,pC2.rot) < tol);

    end

    function pC = matchDefault(pC)
      % reuse the default convention if it describes the same alignment
      %
      % Data that is plotted the default way should refer to the one
      % default instance instead of an equivalent copy of it. Changing
      % <plottingConvention.default.html plottingConvention.default>, e.g.
      % by |plotx2north|, then applies to this data as well.

      pCd = plottingConvention.default;
      if isapprox(pC,pCd), pC = pCd; end

    end

    function plot(pC, varargin)

      ax = get_option(varargin,'parent');
      if isempty(ax), ax = gca; end

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
    
    function pC = default(pC)
      
      if nargin == 1 % new default
        ss = specimenSymmetry(pC);
        ss.makeDefault;
      else
        ss = specimenSymmetry.default;
        pC = ss.how2plot;
      end
    end
    
    function pC = default3D
      pC = plottingConvention(vector3d(-10,-5,2),vector3d(1,-2,0));
    end
   

    function guard = beginCameraUpdate(ax)
      % suppress camera notifications until the camera is consistent again
      %
      % The orientation of an axes is spread over several camera properties,
      % but they can only be assigned one at a time and each assignment fires
      % its own PostSet event. Listeners that read the orientation back (e.g.
      % the scale bar, via <plottingConvention.getView>) would therefore first
      % see an intermediate state - typically the new viewing direction still
      % paired with the previous up vector - lay themselves out for it, and
      % then immediately do it all again for the final state.
      %
      % Bracketing the assignments with this guard marks the axes as
      % mid-update, which those listeners check and skip. Releasing the guard
      % - by clearing the returned object, i.e. at the latest when the calling
      % function returns, also on error - unmarks the axes and fires exactly
      % one notification, on the finished camera.
      %
      % Syntax
      %   guard = plottingConvention.beginCameraUpdate(ax);
      %   ax.CameraPosition = ...; ax.CameraUpVector = ...;
      %
      % Input
      %  ax - axes handle
      %
      % Output
      %  guard - onCleanup object, keep alive for the duration of the update
      %
      % See also
      % plottingConvention/setView scaleBar/update

      setappdata(ax,'MTEXcameraUpdate',true);
      guard = onCleanup(@() plottingConvention.endCameraUpdate(ax));
    end

    function endCameraUpdate(ax)
      % counterpart of beginCameraUpdate - see there

      if ~isgraphics(ax), return; end
      if isappdata(ax,'MTEXcameraUpdate'), rmappdata(ax,'MTEXcameraUpdate'); end

      % re-assigning an unchanged property still fires its PostSet event, so
      % this delivers the single notification the listeners were kept from
      % during the update - and unlike simply relying on the last assignment
      % of the update itself, it also reaches them when that assignment did
      % not actually change anything
      up = ax.CameraUpVector;
      ax.CameraUpVector = up;
    end

    function pC = getView(ax)
      % reconstruct the plottingConvention from the current camera state
      %
      % This is the inverse operation to <plottingConvention.setView>: it
      % reads back the orientation that is currently applied to an axis.
      % Together they allow other graphics objects (e.g. the scale bar) to
      % stay in sync with the axis no matter whether the same convention was
      % modified in place or a different one was applied via setView.
      %
      % Syntax
      %   pC = plottingConvention.getView(ax)
      %   pC = plottingConvention.getView      % uses gca
      %
      % Input
      %  ax - axes handle (default: gca)
      %
      % Output
      %  pC - @plottingConvention
      %
      % See also
      % plottingConvention/setView

      if nargin == 0, ax = gca; end

      % In both the map and the 3d branch of setView the camera ends up with
      %   CameraPosition - CameraTarget  parallel to  outOfScreen
      %   CameraUpVector                 equal to     north
      % so we can simply read those two directions back.
      camDir = ax.CameraPosition - ax.CameraTarget;   % points towards viewer
      up     = ax.CameraUpVector;

      outOfScreen = normalize(vector3d(camDir(1),camDir(2),camDir(3)));
      up          = vector3d(up(1),up(2),up(3));

      % MATLAB does not require CameraUpVector to be perpendicular to the
      % viewing direction - what points north on screen is only the component
      % of it orthogonal to outOfScreen. Projecting instead of taking the up
      % vector as is also keeps this working while the camera is halfway
      % through an update: setView assigns CameraPosition before
      % CameraUpVector, and the CameraPosition PostSet listeners (e.g. the
      % scale bar's) run in between, i.e. on a new camera direction paired
      % with the still old up vector.
      north = up - dot(up,outOfScreen) * outOfScreen;

      % rebuild the rotation consistent with the getters
      %   outOfScreen = rot * Z,  north = rot * Y
      pC = plottingConvention;
      if norm(north) <= 1e-10 * norm(up) % up is along the viewing direction
        pC.rot = rotation.map(vector3d.Z,outOfScreen); % no roll defined
      else
        pC.rot = rotation.map(vector3d.Z,outOfScreen,vector3d.Y,normalize(north));
      end
    end



    function pC = ij
      % Map plotting conventions to match SEM image display and MATLAB
      % 'axis ij' reference frames.
      % Use with import flag "convertEuler2SpatialReferenceFrame" for
      % most modern SEM systems.
      % Useful for producing comparable map plots in MTEX,
      % MATLAB and SEM/EBSD software.
      %
      % pC = plottingConvention.ij;
      %
      % The rotation - 180 degree about x, i.e. z -> -z and y -> -y - is
      % set directly instead of by plottingConvention(-vector3d.Z,
      % vector3d.X). Since this is the default convention, @vector3d can
      % not be used here: its class default how2plot asks for exactly this
      % convention, which MATLAB rejects as a circular initialisation.
      pC = plottingConvention;
      pC.rot = rotation(quaternion(0,1,0,0));
    end
    
    function pC = edax(setting)
      % Map plotting conventions to match EDAX Euler reference frame
      % A1/A2/A3.
      % Use with import flag "convertSpatial2EulerReferenceFrame" on
      % EDAX systems.
      % Useful for producing comparable orientation plots in MTEX and EDAX software.
      %
      % Input:
      %  setting = edax setting number (numeric) (default = 2)
      
      if nargin<1
        setting = 2;
        warning("No EDAX reference frame setting specified. Defaulting to setting 2.")
      end
      switch setting
        case 1
          outOfScreen = vector3d.Z;
          east = vector3d.Y;
        case 2
          outOfScreen = vector3d.Z;
          east = -vector3d.Y;
        case 3
          outOfScreen = vector3d.Z;
          east = vector3d.X;
        case 4
          outOfScreen = vector3d.Z;
          east = -vector3d.X;
      end
      pC = plottingConvention(outOfScreen,east);
    end

  end

end

