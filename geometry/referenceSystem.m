classdef referenceSystem < handle

  properties
    name = "XYZ" % name of the reference system
    sP           % screenProjection
  end

  methods
    
    function rS = referenceSystem(name)
      
      if nargin > 0, rS.name = name; end

      % new screen projection object for each new reference system
      rS.sP = screenProjection;

      persistent allHandles
      if nargin>0 && strcmp(name,'clear')
        allHandles = {};
        return
      end

      if isempty(allHandles)
        allHandles = {rS};
      else
    
        ind = cellfun(@(x) strcmp(rS.name,x.name),allHandles,'UniformOutput',true);

        if any(ind)
          rS = allHandles{ind};
        else
          allHandles{end+1} = rS;
        end
      end
    end

    function str = char(rS, varargin)
      
      str = char(rS.name);
        
      if ~getMTEXpref('generatingHelpMode')
        id = pushTemp(rS);
        str = ['<a href="matlab: display(pullTemp(' int2str(id) '),''variableName'',''refSystem'')">' str '</a>'];
      end

    end

    function display(rS,varargin)
      
      displayClass(rS,inputname(1),'moreInfo',char(rS.name),varargin{:});
      
      disp(' ');

      disp('default plotting convention: ');
      disp(['  out of screen:  (' char(rS.sP.outOfScreen) ')']);
      disp(['  east of screen: (' char(rS.sP.east) ')']);

    end

  end

  methods (Static=true)
  
  end

end