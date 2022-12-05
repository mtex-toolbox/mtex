classdef screenProjection < handle
  %SCREENPROJECTION Summary of this class goes here
  %   Detailed explanation goes here
  
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

