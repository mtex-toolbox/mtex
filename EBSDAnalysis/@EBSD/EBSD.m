classdef EBSD < phaseList & dynProp & dynOption
  % constructor
  %
  % *EBSD* is the low level constructor for an *EBSD* object representing EBSD
  % data. For importing real world data you might want to use the predefined
  % <ImportEBSDData.html EBSD interfaces>. You can also simulate EBSD data
  % from an ODF by the command <ODF.calcEBSD.html calcEBSD>.
  %
  % Syntax
  %   ebsd = EBSD(rotations,phases,CSList)
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
    A_D = []              % adjecency matrix of the measurement points
  end
  
  methods
    
    function ebsd = EBSD(rot,phases,CSList,varargin)
      %
      % Syntax 
      %   EBSD(rot,phases,CSList)
      
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
        return
      end
      
      
      ebsd.rotations = rotation(rot);
      ebsd = ebsd.init(phases,CSList);      
      ebsd.id = (1:numel(phases)).';
            
      % extract additional properties
      ebsd.prop = get_option(varargin,'options',struct);
                  
      % get unit cell
      if check_option(varargin,'uniCell')
        ebsd.unitCell = get_option(varargin,'unitCell',[]);
      else
        ebsd = ebsd.updateUnitCell;
      end
      
      % remove ignore phases
      if check_option(varargin,'ignorePhase')
        
        del = ismember(ebsd.phaseMap(ebsd.phaseId),get_option(varargin,'ignorePhase',[]));
        ebsd = subSet(ebsd,~del);
        
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
        ebsd.prop.grainId = zeros(length(ebsd),1);
        ebsd.prop.grainId(ebsd.isIndexed) = grainId;
      elseif numel(grainId) == 1
        ebsd.prop.grainId = grainId * ones(length(ebsd),1);
      else
        error('The list of grainId has to have the same size as the list of ebsd data.')
      end
    end
      
    function ori = get.orientations(ebsd)
      ori = orientation(ebsd.rotations,ebsd.CS);
    end
    
    function ebsd = set.orientations(ebsd,ori)
      
      ebsd.rotations = rotation(ori);
      ebsd.CS = ori.CS;
            
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
      
end
