classdef EBSD < phaseList & dynProp & dynOption
  % class representing EBSD measurements
  %
  % In MTEX a variable of type *EBSD* is used to store EBSD measurements
  % as a table with rows containing the orientation, the spatial
  % coordinates and the phase of each indiviudal measurement.
  %
  % Syntax
  %
  %   prop.xy = xy;
  %   prop.mad = mad;
  %   CSList = {'notIndexed',CS1,CS2,CS3};
  %   rot = rotation.byEuler(phi1,Phi,phi2);
  %
  %   ebsd = EBSD(rot,phaseId,CSList,prop)
  %   ebsd = EBSD(rot,phaseId,CSList,prop,'unitCell',unitCell)
  %
  % Input
  %  rot         - @rotation
  %  phaseId     - phase as index to CSList
  %  CS1,CS2,CS3 - @crystalSymmetry
  %  prop        - struct with properties, xy is mandatory
  %  unitCell    - vertices a single pixel
  %
  % Options
  %  phase    - specifing the phase of the EBSD object
  %  options  - struct with fields holding properties for each orientation
  %  xy       - spatial coordinates n x 2, where n is the number of input orientations
  %  unitCell - for internal use
  %
  % Class Properties
  %  id        - unique id of each pixel
  %  CSList    - cell list of @crystalSymmetry
  %  phaseId   - phase of each pixel as entry of CSList
  %  phase     - phase of each pixel as imported 
  %  phaseMap  - convert between phase = phaseMap(phaseId)
  %  rotations - @rotation of each pixel
  %  x, y      - coordinates of the center of each pixel 
  %  scanUnit  - unit of the x,y coordinates (um is default)
  %  prop      - auxilary properties, e.g., MAD, BC, mis2mean
  %  isIndexed - is pixel indexed or not
  %  indexedPhaseId - phaseIds of all indexed phases
  %
  % Derived Classes
  %  @EBSDsquare - EBSD data measured on a square grid
  %  @EBSDhex    - EBSD data measured on a hex grid
  %
  % See also
  % EBSDImport EBSDSelect EBSDPlotting GrainReconstruction
  
  % properties with as many rows as data
  properties
    id = []               % unique id's starting with 1    
    rotations = rotation  % rotations without crystal symmetry
  end
  
  % general properties
  properties
    scanUnit = 'um'       % unit of the x,y coordinates
    unitCell = []         % cell associated to a measurement
  end
   
  properties (Dependent = true)
    orientations    % rotation including symmetry
    grainId         % id of the grain to which the EBSD measurement belongs to
    mis2mean        % misorientation to the mean orientation of the corresponding grain
  end
  
  properties (Access = protected)
    A_D = []        % adjecency matrix of the measurement points
  end
  
  methods
    
    function ebsd = EBSD(rot,phases,CSList,prop,varargin)
      
      if nargin == 0, return; end            
      
      % copy constructor
      if isa(rot,'EBSD')
        ebsd.id = rot.id(:);
        ebsd.rotations = rot.rotations(:);
        ebsd.phaseId = rot.phaseId(:);
        ebsd.phaseMap = rot.phaseMap;
        ebsd.CSList = rot.CSList;
        ebsd.unitCell = rot.unitCell;
        ebsd.scanUnit = rot.scanUnit;
        ebsd.A_D = rot.A_D;
        for fn = fieldnames(rot.prop)'
          ebsd.prop.(char(fn))= rot.prop.(char(fn))(:);
        end
        ebsd.opt = rot.opt;
        return
      end
      
      ebsd.rotations = rotation(rot);
      ebsd = ebsd.init(phases,CSList);      
      ebsd.id = (1:numel(phases)).';
            
      % extract additional properties
      ebsd.prop = prop;
                  
      % get unit cell
      if check_option(varargin,'unitCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd = ebsd.updateUnitCell;
      end
      
    end
    
    % --------------------------------------------------------------

    function varargout = size(ebsd,varargin)
      [varargout{1:nargout}] = size(ebsd.id,varargin{:});
    end
    
    function ori = get.mis2mean(ebsd)      
      ori = ebsd.prop.mis2mean;
      try
        ori = orientation(ori,ebsd.CS,ebsd.CS);
      catch        
      end
    end
        
    function ebsd = set.mis2mean(ebsd,ori)
      
      if length(ori) == length(ebsd)
        ebsd.prop.mis2mean = rotation(ori(:));
      elseif length(ori) == nnz(ebsd.isIndexed)
        ebsd.prop.mis2mean = rotation.id(length(ebsd),1);
        ebsd.prop.mis2mean(ebsd.isIndexed) = rotation(ori);
      elseif length(ori) == 1
        ebsd.prop.mis2mean = rotation(ori) .* rotation.id(length(ebsd),1);
      else
        error('The list of mis2mean has to have the same size as the list of ebsd data.')
      end
      
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
      if numel(grainId) == length(ebsd)
        ebsd.prop.grainId = reshape(grainId,size(ebsd.id));
      elseif numel(grainId) == nnz(ebsd.isIndexed)
        ebsd.prop.grainId = zeros(size(ebsd));
        ebsd.prop.grainId(ebsd.isIndexed) = grainId;
      elseif numel(grainId) == 1
        ebsd.prop.grainId = grainId * ones(size(ebsd));
      else
        error('The list of grainId has to have the same size as the list of ebsd data.')
      end
    end
      
    function ori = get.orientations(ebsd)
      if isempty(ebsd)
        ori = orientation;
      else
        ori = orientation(ebsd.rotations,ebsd.CS);
        
        % set not indexed orientations to nan
        if ~all(ebsd.isIndexed), ori(~ebsd.isIndexed) = NaN; end
        
      end
    end
    
    function ebsd = set.orientations(ebsd,ori)
      
      if ~isempty(ebsd)
        if isa(ori,'quaternion')
          ebsd.rotations = rotation(ori);
          ebsd.CS = ori.CS;
        elseif isnan(ori) && length(ori)==1
          ebsd.rotations = rotation.nan(size(ebsd));
        else
          error('type mismatch');
        end
      end
            
    end
           
%     function dx = get.dx(ebsd)
%       uc = ebsd.unitCell;
%       if size(uc,1) == 4
%         dx = max(uc(:,1)) - min(uc(:,1));
%       elseif size(uc,1) == 6
%         dx = max(uc(:,1)) - min(uc(:,1));
%       else
%         dx = inf;
%       end
%     end
%     
%     function dy = get.dy(ebsd)
%       uc = ebsd.unitCell;
%       if size(uc,1) == 4
%         dy = max(uc(:,2)) - min(uc(:,2));
%       elseif size(uc,1) == 6
%         dy = max(uc(:,2)) - min(uc(:,2));
%       else
%         dy = inf;
%       end
%     end
    
  end
  
  methods (Static = true)
    
    [ebsd,interface,options] = load(fname,varargin)
    
  end
      
end
