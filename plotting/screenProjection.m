classdef screenProjection < handle
  % converts between screen and reference frame coordinates
  %
  % Holds the rotation that takes screen coordinates - east, north, out of
  % the screen - to the coordinates of a reference frame, and turns that into
  % a camera for an axes.
  %
  % Work in progress: project and iproject are still empty, and the declared
  % west, south and intoScree have no getter yet. Nothing in MTEX uses this
  % class so far.
  %
  % Syntax
  %   sP = screenProjection;
  %   sP.outOfScreen = vector3d.Z;
  %   sP.setView(gca)
  %
  % Class Properties
  %  rot         - @rotation from screen to reference coordinates
  %  east        - @vector3d pointing right on the screen
  %  north       - @vector3d pointing up on the screen
  %  outOfScreen - @vector3d pointing at the viewer
  %  viewOpt     - the corresponding axes camera properties
  %
  % See also
  % plottingConvention referenceFrame
  %
  
  properties
    rot = rotation.id % screen coordinates to reference coordinates
  end
  
  properties (Dependent=true)
    east
    west
    north
    south
    outOfScreen
    intoScree
    viewOpt
  end

  methods

    function sP = screenProjection(varargin)
      
    end
    
    function [x,y] = project(sP,v)
      % project vector3d to screen

      
    end

    function v = iproject(sP,x,y)
      % project 

      
    end


    function setView(sP,ax)

      if nargin == 1, ax = gca; end

      set(ax,sP.viewOpt{:});
    end

    function opt = get.viewOpt(sP)
      opt = {'CameraPosition',sP.outOfScreen.xyz,...
        "CameraUpVector",sP.north.xyz};
    end


    function v = get.outOfScreen(sP) 
      v = sP.rot * vector3d.Z;
    end

    function set.outOfScreen(sP,n)

      % compute new east vector "e" from the old east vector "E" such that
      % e ⟂ n
      % 
      newNorth = cross(n,cross(n,sP.north));
     
      sP.rot = rotation.map(zvector,n,yvector,newNorth);

    end


    function v = get.east(sP) 
      
      v = sP.rot * vector3d.X;

    end

    function set.east(sP,e)

      % compute new east vector "e" from the old east vector "E" such that
      % e ⟂ n
      % 
      newNorth = cross(e,cross(e,sP.north));
     
      sP.rot = rotation.map(xvector,e,yvector,newNorth);

    end

    function v = get.north(sP) 
      
      v = sP.rot * vector3d.Y;

    end

  end

  methods (Static=true)
  
    function test
      grainsR = rotate(grains,rotation.rand);
      plot(grainsR,grainsR.meanOrientation,'micronbar','off');
      sP.outOfScreen = grainsR.N; sP.setView(gca)
    end

  end

end

