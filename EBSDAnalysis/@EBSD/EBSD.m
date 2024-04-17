classdef EBSD < phaseList & dynProp & dynOption
  % class representing EBSD measurements
  %
  % In MTEX a variable of type <EBSD.EBSD.html |EBSD|> is used to store
  % EBSD measurements as a table with rows containing the orientation, the
  % spatial coordinates and the phase of each individual measurement.
  %
  % Syntax
  %
  %   pos = vector3d(x,y,z);
  %   prop.mad = mad;
  %   CSList = {'notIndexed',CS1,CS2,CS3};
  %   rot = rotation.byEuler(phi1,Phi,phi2);
  %
  %   ebsd = EBSD(rot,phaseId,CSList,prop)
  %   ebsd = EBSD(rot,phaseId,CSList,prop,'unitCell',unitCell)
  %
  % Input
  %  pos         - @vector3d
  %  rot         - @rotation
  %  phaseId     - phase as index to CSList
  %  CS1,CS2,CS3 - @crystalSymmetry
  %  prop        - struct with properties (optional)
  %
  % Options
  %  unitCell - @vector3d
  %
  % Class Properties
  %  id        - unique id of each pixel
  %  CSList    - cell list of @crystalSymmetry
  %  phaseId   - phase of each pixel as entry of CSList
  %  phase     - phase of each pixel as imported 
  %  phaseMap  - convert between phase = phaseMap(phaseId)
  %  rotations - @rotation of each pixel
  %  pos       - @vector3d, coordinates of the center of each pixel 
  %  scanUnit  - unit of the x,y coordinates (um is default)
  %  prop      - auxiliary properties, e.g., MAD, BC, mis2mean
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
    pos = vector3d        % positions of the EBSD measurements
  end

  properties (Dependent = true)
    xyz           %
    x             %
    y             %
    z             %  
    orientations  % rotation including symmetry
    grainId       % id of the grain to which the EBSD measurement belongs to
    mis2mean      % misorientation to the mean orientation of the corresponding grain   
  end

  % general properties
  properties
    scanUnit = 'um'       % unit of the x,y coordinates
    unitCell = vector3d   % cell associated to a measurement
    N = zvector           % normal direction of the measurement plane
  end
   
  properties (Dependent = true)
    dPos          % spacing of the positions
    rot2Plane  % rotation to xy plane
    plottingConvention % plotting convention
  end

  properties (Access = protected)
    A_D = []        % adjacency matrix of the measurement points
  end
  
  methods
    
    function ebsd = EBSD(pos,rot,phases,CSList,prop,varargin)
      
      if nargin == 0, return; end            
      
      % copy constructor
      if isa(pos,'EBSD')
        ebsd.id = pos.id(:);
        ebsd.rotations = pos.rotations(:);
        ebsd.pos = pos.pos(:);
        ebsd.phaseId = pos.phaseId(:);
        ebsd.phaseMap = pos.phaseMap;
        ebsd.CSList = pos.CSList;
        ebsd.unitCell = pos.unitCell;
        ebsd.scanUnit = pos.scanUnit;
        ebsd.A_D = pos.A_D;
        if nargin > 4 && isstruct(prop)
          for fn = fieldnames(pos.prop)'
            ebsd.prop.(char(fn))= pos.prop.(char(fn))(:);
          end
        end
        ebsd.opt = pos.opt;

        ebsd = ebsd.subSet(~isnan(ebsd.phaseId));
        return
      end
      
      % extract spatial coordinates
      if ~isa(pos,"vector3d")
        if size(pos,2)==3
          pos = vector3d.byXYZ(pos);
        else
          pos = vector3d.byXYZ(pos(:,1),pos(:,2),0);
        end
      end
      ebsd.pos = pos;

      ebsd.rotations = rotation(rot);
      ebsd = ebsd.init(phases,CSList);      
      ebsd.id = (1:numel(phases)).';
            
      % extract additional properties
      ebsd.prop = prop;

      % remove nan positions
      ebsd = ebsd.subSet(~isnan(ebsd.pos));

      % get unit cell
      ebsd = ebsd.updateUnitCell(get_option(varargin,'unitCell'));
            
      ebsd.N = perp(ebsd.unitCell);

    end
    
    % --------------------------------------------------------------

    function varargout = size(ebsd,varargin)
      [varargout{1:nargout}] = size(ebsd.id,varargin{:});
    end
    

    function x = get.x(ebsd)
      x = ebsd.pos.x;
    end

    function ebsd = set.x(ebsd,x)
      ebsd.pos.x = x;
    end

    function y = get.y(ebsd)
      y = ebsd.pos.y;
    end

    function ebsd = set.y(ebsd,y)
      ebsd.pos.y = y;
    end

    function z = get.z(ebsd)
      z = ebsd.pos.z;
    end

    function ebsd = set.z(ebsd,z)
      ebsd.pos.z = z;
    end

    function xyz = get.xyz(ebsd)
      xyz = ebsd.pos.xyz;
    end

    function ebsd = set.xyz(ebsd,xyz)
      ebsd.pos = vector3d.byXYZ(xyz);
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
      elseif isscalar(ori)
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
      elseif isscalar(grainId)
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
        elseif isnan(ori) && isscalar(ori)
          ebsd.rotations = rotation.nan(size(ebsd));
        else
          error('type mismatch');
        end
      end
            
    end
           
    function d = get.dPos(ebsd)
      d = min(norm(ebsd.unitCell(1) - ebsd.unitCell(2:end)));
    end

    function rot = get.rot2Plane(ebsd)
      rot = rotation.map(ebsd.N,vector3d.Z);
    end

    function pC = get.plottingConvention(ebsd)
      pC = ebsd.pos.plottingConvention;
    end
    
    function ebsd = set.plottingConvention(ebsd,pC)
      ebsd.pos.plottingConvention = pC;
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

    function ebsd = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % transform to class if not yet done
      if isa(s,'EBSD')
        ebsd = s; 
      else
        ebsd = EBSD(vector3d,s.rot,s.phaseId,s.CSList,s.prop);
        ebsd.opt = s.opt;
        ebsd.scanUnit = s.scanUnit;
      end
      
      % ensure pos is set correctly
      if isfield(ebsd.prop,'x')
        ebsd.pos = vector3d(s.prop.x,s.prop.y,0);
        ebsd.prop = rmfield(ebsd.prop,{'x','y'});
      end
            
      % ensure unitCell is vector3d
      if ~isa(ebsd.unitCell,'vector3d')
        ebsd.unitCell = vector3d(ebsd.unitCell(:,1),ebsd.unitCell(:,2),0);
      end

    end

  end
      
end
