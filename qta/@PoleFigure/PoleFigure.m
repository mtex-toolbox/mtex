classdef PoleFigure < dynOption


   
  properties
    h = Miller()        % crystal direction
    r = vector3d()      % specimen directions
    intensities = []    % diffraction intensities
    c = []              % superposition coefficients
    bg = []             % background
    SS                  % specimen symmetry
  end
  
  properties (Dependent = true)  
    CS    
  end
  
  methods
  
  
    function P = PoleFigure(h,r,data,varargin)
      % constructor 
      %
      % *PoleFigure* is the low level constructor. For importing real world data
      % you might want to use the predefined [[ImportPoleFigureData.html,interfaces]]
      %
      % Input
      %  h     - crystal directions (@vector3d | @Miller)
      %  r     - specimen directions (@S2Grid)
      %  intensities - diffraction counts (double)
      %  CS,SS - crystal, specimen @symmetry
      %
      % Options
      %  superposition - weights for superposed crystal directions
      %  background    - background intensities
      %
      % See also
      % ImportPoleFigureData loadPoleFigure loadPoleFigure_generic
      
      if nargin == 0, return;end
      
      P.h = argin_check(h,{'vector3d','Miller'});
      P.r = argin_check(r,{'vector3d','S2Grid'});
      if ~check_option(varargin,'complete'), P.r.antipodal = true;end
      
      P.intensities= argin_check(data,{'double','int'});
      assert(numel(P.intensities) == length(P.r),...
        'Number of diffraction intensitites is not equal to the number of specimen directions!');
      P.bg = get_option(varargin,'background',[],'double');
      P.c = reshape(get_option(varargin,'superposition',ones(1,length(h)),'double'),1,[]);
      P.c= P.c ./sum(P.c);
            
      P.SS = get_option(varargin,'SS',symmetry);
      
    end
    
    function pf = set.CS(pf,CS)
      
      pf.h.CS = CS;
            
    end
    
    function CS = get.CS(pf)
      
      CS = pf.h.CS;
      
    end
    
  end 
end
