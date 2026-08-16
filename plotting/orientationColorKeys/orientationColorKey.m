classdef orientationColorKey < handle
  % abstract class for defining (mis)orientation color keys
  %
  % Class Properties
  %  CS1 - @crystalSymmetry
  %  CS2 - @crystalSymmetry of a second phase for misorientations
  %  antipodal - logical
  %
  % See also
  % BungeColorKey, ipfColorKey, ipfHSVKey, ipfTSLKey, ipfHKLKey, ipfSpotKey
  
  properties
    CS1 = crystalSymmetry % crystal symmetry
    CS2 = specimenSymmetry.default % crystal symmetry of a second phase for misorientations
    antipodal = false
  end
   
  methods
    
    function oCK = orientationColorKey(ebsd,varargin)
      if nargin == 0, return; end
      if isa(ebsd,'EBSD') || isa(ebsd,'grain2d')
        oCK.CS1 = ebsd.CS;
        oCK.CS2 = specimenSymmetryFor(ebsd.how2plot);
      elseif isa(ebsd,'orientation')
        oCK.CS1 = ebsd.CS;
        oCK.CS2 = ebsd.SS;
        oCK.antipodal = ebsd.antipodal;
      elseif isa(ebsd,'grainBoundary')
        cs = ebsd.CS;
        oCK.CS1 = cs(1);
        oCK.CS2 = cs(2);
        
        oCK.antipodal = all(diff(ebsd.phaseId,[],2)==0);
      elseif isa(ebsd,'symmetry')
        oCK.CS1 = ebsd;
      end
      
      if nargin > 1 && isa(varargin{1},'symmetry')
        oCK.CS2 = varargin{1};
      end

      oCK.antipodal = oCK.antipodal || check_option(varargin,'antipodal');

    end
      
    function plot(oCK,varargin)
      % plot an color bar

      if oCK(1).antipodal
        flag = 'antipodal';
      else
        flag = '';
      end
      oS = newODFSectionPlot(oCK(1).CS1,oCK(1).CS2,...
        flag,varargin{:});

      ori = oS.makeGrid(varargin{:});
      rgb = oCK.orientation2color(ori);
      
      if numel(rgb) == length(ori)
        varargin = [{'smooth'},varargin];
      else
        varargin = [{'surf'},varargin];
      end
      plot(oS,rgb,varargin{:});

    end

    function display(oCK,varargin)
      % standard output
      %
      % A color key maps a pair of reference systems to colors, so the
      % header states that pair the way @orientation does - the key for
      % Titanium in the specimen frame reads "Titanium (Alpha) → y↑→x".
      % Below it only what distinguishes this key from a default one,
      % rather than MATLAB's dump of [1x1 crystalSymmetry] handles.

      refSystems = [char(oCK(1).CS1,'compact') ' ' getMTEXpref('arrowChar') ...
        ' ' char(oCK(1).CS2,'compact')];

      displayClass(oCK(1),inputname(1),'moreInfo',refSystems,varargin{:});

      if ~isscalar(oCK)
        disp(['  size: ' size2str(oCK)]);
        disp(' ');
        return
      end

      if ~check_option(varargin,'skipHeader'), disp(' '); end

      props = {}; propV = {};
      if oCK.antipodal
        props{end+1} = 'antipodal'; propV{end+1} = 'true'; %#ok<AGROW>
      end

      [p,v] = keyRows(oCK);
      props = [props,p]; propV = [propV,v];

      if ~isempty(props)
        cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');
        disp(' ');
      end

    end

    function [props,propV] = keyRows(~)
      % the rows a concrete key adds to its display
      %
      % Overridden by the concrete keys - the abstract key has no settings
      % of its own beyond the reference systems already in the header.

      props = {}; propV = {};
    end

  end

  methods (Abstract = true)
    c = orientation2color(oM,ori,varargin)
  end
end

