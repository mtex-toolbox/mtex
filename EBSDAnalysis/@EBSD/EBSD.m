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
  %   ebsd = EBSD(pos,rot,phaseId,CSList,prop)
  %   ebsd = EBSD(pos,rot,phaseId,CSList,prop,'unitCell',unitCell)
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
    dPos       % spacing of the positions
    rot2Plane  % rotation to xy plane
    frame      % the specimen reference frame (carried by pos)
    how2plot   % plotting convention - read only
    % a convention belongs to a reference frame, see plottingConvention.default
    plottingConvention % plotting convention
    EulerCorrection    % EulerXYZ -> mapXYZ, correction for inconsistent reference frames
  end

  properties (Access = protected)
    A_D = []        % adjacency matrix of the measurement points
    Euler2Map = rotation.id  % EulerXYZ -> mapXYZ
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
        % a map shaped property is flattened along with pos, an N x k one is not
        for fn = fieldnames(pos.prop)'
          p = pos.prop.(char(fn));
          if ~(size(p,2) > 1 && size(p,1) == length(pos)), p = p(:); end
          ebsd.prop.(char(fn)) = p;
        end
        ebsd.opt = pos.opt;
        ebsd.N = pos.N;
        ebsd.Euler2Map = pos.Euler2Map;

        ebsd = ebsd.subSet(~isnan(ebsd.phaseId));
        return
      end
      
      % extract spatial coordinates
      if ~isa(pos,"vector3d")
        if size(pos,2)==3
          pos = vector3d.byXYZ(pos);
        else
          pos = vector3d(pos(:,1),pos(:,2),0);
        end
      end
      % an @EBSD is a flat list of measurements - map shaped data is what the
      % grid classes @EBSDsquare / @EBSDhex are for, so normalize the input
      sPos = size(pos);
      ebsd.pos = pos(:);

      CSList = ensureCSArray(CSList);

      if class(rot) ~= "rotation", rot = rotation(rot); end
      ebsd.rotations = rot(:);
      if check_option(varargin,'phaseMap')
        ebsd.phaseId = phases(:);
        ebsd.CSList = CSList;
        ebsd.phaseMap = get_option(varargin,'phaseMap');
      else
        ebsd = ebsd.init(phases,CSList);
      end

      ebsd.id = (1:numel(phases)).';

      % extract additional properties, flattening those in the shape of pos
      if isstruct(prop)
        for fn = fieldnames(prop).'
          if isequal(size(prop.(char(fn))),sPos)
            prop.(char(fn)) = prop.(char(fn))(:);
          end
        end
      end
      ebsd.prop = prop;

      % remove nan positions
      if any(isnan(ebsd.pos)), ebsd = ebsd.subSet(~isnan(ebsd.pos)); end

      % get unit cell - varargin carries the grid options, the hint goes last
      ebsd = ebsd.updateUnitCell(get_option(varargin,'unitCell'),...
        varargin{:},'hint',get_option(varargin,'unitCellHint'));
            
      ebsd.N = perp(ebsd.unitCell);

      % unitCell and N live in the very same frame as the positions
      ebsd.unitCell.frame = ebsd.pos.frame;
      ebsd.N.frame = ebsd.pos.frame;

      % orientations of not indexed pixels should be nan
      ebsd.rotations(~ebsd.isIndexed) = nan;

      % phase of nan orientations should be notIndexed
      ebsd.phaseId(isnan(ebsd.rotations)) = 1;

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
        mtexError(' No grainId stored in the EBSD variable. \n%s\n\n%s\n',...
          ' Use the following command to store grainIds within EBSD data',...
          ' [grains,ebsd] = calcGrains(ebsd)')
      end
    end
    
    function ebsd = set.grainId(ebsd,grainId)

      % translate the old syntax [grains,ebsd.grainId] = calcGrains(ebsd('indexed'))
      if isa(grainId,'EBSD')

        warning('MTEX:calcGrains:oldSyntax',['The syntax\n\n' ...
          '  [grains,ebsd.grainId] = calcGrains(ebsd)\n\n' ...
          'has been replaced by\n\n  [grains,ebsd] = calcGrains(ebsd)\n\n' ...
          'It still works, but is deprecated. Switch this warning off by\n\n'...
          '  warning(''off'',''MTEX:calcGrains:oldSyntax'')\n']);

        ebsdNew = grainId;

        if ~ebsdNew.hasGrainId
          error('The assigned EBSD variable does not contain any grainId.')
        end

        [isKnown,pos] = ismember(ebsd.id(:),ebsdNew.id(:));

        if ~any(isKnown)
          error(['The assigned EBSD variable does not contain any of the ' ...
            'pixels of the EBSD variable it is assigned to.'])
        end

        grainId = zeros(size(ebsd.id));
        grainId(isKnown) = ebsdNew.grainId(pos(isKnown));

      end

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

      % EBSD data that do not belong to a grain are set to notIndexed
      ebsd.phaseId(ebsd.grainId == 0) = 1;

      % phaseId should be the same within one grain 
      %ind = ebsd.grainId>0;
      %if nnz(ind)
      %  grain2phaseId = majorityVote(ebsd.grainId(ind),ebsd.phaseId(ind));
      %  newPhaseId = grain2phaseId(ebsd.grainId(ind));
      %  hasChanged = false(numel(ebsd),1);
      %  hasChanged(ind) = ebsd.phaseId(ind) ~= newPhaseId;
      %  ebsd.phaseId(ind) = newPhaseId;
      %  ebsd.rotations(hasChanged) = NaN;
      %end
      
    end
      
    function out = hasGrainId(ebsd)
      out = isfield(ebsd.prop,'grainId');
    end

    function ori = get.orientations(ebsd)
      if isempty(ebsd)
        ori = orientation;
      else
        ori = orientation(ebsd.rotations,ebsd.CS,...
          specimenSymmetryFor(ebsd.pos.frame));

        % set not indexed orientations to nan
        if ~all(ebsd.isIndexed(:)), ori(~ebsd.isIndexed) = NaN; end
        
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
           
    function ebsd = set.unitCell(ebsd,uC)
      % calcUnitCell returns the cell as an n x 2 list of coordinates while
      % the property is a vector3d, so the documented way of recomputing a
      % cell, ebsd.unitCell = calcUnitCell(xy), used to store a raw double
      % that every reader of the property then tripped over. Convert here
      % rather than at each call site.
      if isnumeric(uC)
        if isempty(uC)
          uC = vector3d;
        else
          if size(uC,2) < 3, uC(:,3) = 0; end
          uC = vector3d(uC(:,1),uC(:,2),uC(:,3));
        end
      end
      ebsd.unitCell = uC;
    end

    function d = get.dPos(ebsd)
      d = min(norm(ebsd.unitCell(1) - ebsd.unitCell(2:end)));
    end

    function rot = get.rot2Plane(ebsd)
      if angle(ebsd.N, vector3d.Z,'antipodal')==0
        rot = rotation.id;
      else
        rot = rotation.map(ebsd.N,vector3d.Z);
      end
    end

    function pC = get.plottingConvention(ebsd)
      pC = ebsd.pos.how2plot;
    end
    
    function ebsd = set.plottingConvention(ebsd,pC)
      ebsd.pos.frame = specimenSymmetry.frameFor(pC);
    end

    function pC = get.how2plot(ebsd)
      pC = ebsd.pos.how2plot;
    end


    function fr = get.frame(ebsd)
      fr = ebsd.pos.frame;
    end

    function ebsd = set.frame(ebsd,fr)
      % unitCell and N live in the very same frame as the positions
      ebsd.pos.frame = fr;
      ebsd.unitCell.frame = fr;
      ebsd.N.frame = fr;
    end

    function rot = get.EulerCorrection(ebsd)
      rot = ebsd.Euler2Map;
    end

    function ebsd = set.EulerCorrection(ebsd,rot)
      ebsd.rotations = rot .* inv(ebsd.Euler2Map) .* ebsd.rotations;
      ebsd.Euler2Map = rot;
    end
    
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
        if width(s.id) == 1
          ebsd = EBSD;
        elseif length(s.unitCell) == 6
          % dHex / isRowAlignment are derived from unitCell and pos now, so
          % there is nothing to restore - both are set further down
          ebsd = EBSDhex;
        else
          ebsd = EBSDsquare;
        end
        
        ebsd.opt = s.opt;
        ebsd.id = s.id;
        ebsd.rotations = s.rotations;
        ebsd.phaseId = s.phaseId;
        ebsd.CSList = s.CSList;
        ebsd.prop = s.prop;
        ebsd.scanUnit = s.scanUnit;
        ebsd.phaseMap = s.phaseMap;
        ebsd.unitCell = s.unitCell;

        % everything else the file still carries - not copying pos here is
        % what made an old file arrive empty even when it had saved one
        if isfield(s,'pos') && isa(s.pos,'vector3d'), ebsd.pos = s.pos; end
        if isfield(s,'N') && isa(s.N,'vector3d'), ebsd.N = s.N; end
        if isfield(s,'A_D'), ebsd.A_D = s.A_D; end
      end

      % ensure pos is set correctly
      if isfield(ebsd.prop,'x') && isempty(ebsd.pos)
        ebsd.pos = vector3d(s.prop.x,s.prop.y,0);
        ebsd.prop = rmfield(ebsd.prop,{'x','y'});
      end

      % rebuild pos from the dx / dy an @EBSDsquare stored before 859b62af0
      if isempty(ebsd.pos) && isstruct(s) && ...
          all(isfield(s,{'dx','dy'})) && ~isempty(s.dx)

        [col,row] = meshgrid(1:size(ebsd.id,2),1:size(ebsd.id,1));
        ebsd.pos = vector3d((col-1) * s.dx,(row-1) * s.dy,0);

        warning('MTEX:EBSD:loadobj:posFromStep',...
          ['This file was saved by an MTEX version that stored the grid '...
          'spacing (dx = %g, dy = %g) instead of the pixel positions. '...
          'ebsd.pos was rebuilt from it, with the origin placed at (0,0).'],...
          s.dx,s.dy);
      end

      % ensure unitCell is vector3d
      if ~isa(ebsd.unitCell,'vector3d')
        ebsd.unitCell = vector3d(ebsd.unitCell(:,1),ebsd.unitCell(:,2),0);
      end

      % ensure CSList is vector
      ebsd.CSList = ensureCSArray(ebsd.CSList);

      % keep the frame the map was saved in, re-interned against the register
      if ~isempty(ebsd.pos) && isa(ebsd.pos.frame,'specimenFrame')
        ebsd.frame = referenceFrame.reintern(ebsd.pos.frame);
      end

    end

  end
      
end
