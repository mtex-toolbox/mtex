classdef EBSD < phaseList & dynProp & dynOption & misorientationAnalysis
  % constructor
  %
  % *EBSD* is the low level constructor for an *EBSD* object representing EBSD
  % data. For importing real world data you might want to use the predefined
  % <ImportEBSDData.html EBSD interfaces>. You can also simulate EBSD data
  % from an ODF by the command <ODF.calcEBSD.html calcEBSD>.
  %
  % Syntax
  %   ebsd = EBSD(orientations,CS,...,param,val,...)
  %
  % Input
  %  orientations - @orientation
  %  CS           - crystal / specimen @symmetry
  %
  % Options
  %  phase    - specifing the phase of the EBSD object
  %  options  - struct with fields holding properties for each orientation
  %  xy       - spatial coordinates n x 2, where n is the number of input orientations
  %  unitCell - for internal use
  %
  % See also
  % ODF/calcEBSD EBSD/calcODF loadEBSD
  
  % properties with as many rows as data
  properties
    id = []               % unique id's starting with 1    
    rotations = rotation  % rotations without crystal symmetry
    A_D = []              % adjecency matrix of the measurement points
  end
  
  % general properties
  properties
    scanUnit = 'um'       % unit of the x,y coordinates
    unitCell = []         % cell associated to a measurement
  end
  
  properties (Dependent = true)
    orientations    % rotation including symmetry
    weights         %
    grainId         % id of the grain to which the EBSD measurement belongs to
    mis2mean        % misorientation to the mean orientation of the corresponding grain    
  end
  
  methods
    
    function ebsd = EBSD(rot,phases,CSList,varargin)
      %
      % Syntax 
      %   EBSD(rot,phases,CSList)
      
      if nargin == 0, return; end            
      
      ebsd.rotations = rotation(rot(:));
      ebsd = ebsd.init(phases,CSList);      
      ebsd.id = (1:length(phases)).';
            
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
                  
      % get unit cell
      ebsd.unitCell = get_option(varargin,'unitCell',[]);
      
      % remove ignore phases
      if check_option(varargin,'ignorePhase')
        
        del = ismember(ebsd.phaseMap(ebsd.phaseId),get_option(varargin,'ignorePhase',[]));
        ebsd = subSet(ebsd,~del);
        
      end
            
    end
    
    % --------------------------------------------------------------

    function ori = get.mis2mean(ebsd)      
      ori = ebsd.prop.mis2mean;
      try
        ori = orientation(ori,ebsd.CS,ebsd.CS);
      catch        
      end
    end
        
    function ebsd = set.mis2mean(ebsd,ori)
      ebsd.prop.mis2mean = rotation(ori);      
    end
    
    function grainId = get.grainId(ebsd)
      try
        grainId = ebsd.prop.grainId;
      catch
        error('No grainId stored in the EBSD variable. \n%s\n\n%s\n',...
          'Use the following command to store the grainId within the EBSD data',...
          '[grains,ebsd.grainId] = calcGrains(ebsd)')
      end
    end
    
    function ebsd = set.grainId(ebsd,grainId)
      ebsd.prop.grainId = grainId(:);      
    end
      
    function ori = get.orientations(ebsd)
      ori = orientation(ebsd.rotations,ebsd.CS);
    end
    
    function ebsd = set.orientations(ebsd,ori)
      
      ebsd.rotations = rotation(ori);
      ebsd.CS = ori.CS;
            
    end
           
    function w = get.weights(ebsd)
      if ebsd.isProp('weights')
        w = ebsd.prop.weights;
      else
        w = ones(size(ebsd));
      end      
    end
    
    function ebsd = set.weights(ebsd,weights)
      ebsd.prop.weights = weights;
    end
    
  end
      
end
