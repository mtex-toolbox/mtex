classdef plottingConvention < handle
% class describing the alignment of a reference frame on the screen
  
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

    function pC = plottingConvention(varargin)
      
    end
    
    function [x,y] = project(pC,v)
      % project vector3d to screen

      
    end

    function v = iproject(pC,x,y)
      % project 

      
    end


    function setView(pC,ax)

      if nargin == 1, ax = gca; end

      %cT = get(ax,'CameraTarget');
      
      %set(ax,"CameraPosition",cT + reshape(double(pC.outOfScreen),1,3),...
      %  "CameraUpVector",squeeze(double(pC.north)));

      set(ax,pC.viewOpt{:});
    end

    function opt = get.viewOpt(pC)
      opt = {'CameraPosition',1000*squeeze(double(pC.outOfScreen)),...
        "CameraUpVector",squeeze(double(pC.north))};
    end


    function v = get.outOfScreen(pC) 
      v = pC.rot * vector3d.Z;
    end

    function set.outOfScreen(pC,n)

      % compute new east vector "e" from the old east vector "E" such that
      % e ⟂ n
      % 
      newNorth = cross(n,cross(n,pC.north));
     
      pC.rot = rotation.map(zvector,n,yvector,newNorth);

    end


    function v = get.east(pC) 
      
      v = pC.rot * vector3d.X;

    end

    function set.east(pC,e)

      % compute new east vector "e" from the old east vector "E" such that
      % e ⟂ n
      % 
      newNorth = cross(e,cross(e,pC.north));
     
      pC.rot = rotation.map(xvector,e,yvector,newNorth);

    end

    function v = get.north(pC) 
      
      v = pC.rot * vector3d.Y;

    end

  end

  methods (Static=true)
  
    function test
      grainsR = rotate(grains,rotation.rand);
      plot(grainsR,grainsR.meanOrientation,'micronbar','off');
      pC.outOfScreen = grainsR.N; pC.setView(gca)
    end

  end

end

