classdef EBSD3 < EBSD
  % class representing EBSD measurements
  %
  % In MTEX a variable of type <EBSD3.EBSD3.html |EBSD3|> is used to store
  % 3d EBSD measurements as a table with rows containing the orientation,
  % the spatial coordinates and the phase of each individual measurement.
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
  %  @EBSDcube - EBSD data measured on a cubic grid
  %  @EBSDhex    - EBSD data measured on a hex grid
  %
  % See also
  % EBSDImport EBSDSelect EBSDPlotting GrainReconstruction
  
  methods
    
    function ebsd = EBSD3(varargin)
      
      ebsd = ebsd@EBSD(varargin{:});
      ebsd.N = vector3d.nan;

    end
    
  end
  
  methods (Static = true)
    
    [ebsd,interface,options] = load(fname,varargin)

  end
      
end
