function varargout = get(grains,vname)


properties = get_obj_fields(grains,'GrainSet');
options    = fieldnames(grains.options);

if nargin < 2
  vname = 'error';
end

switch lower(vname)
  
  case {'mean','meanorientation','orientation'}
    
    % check only a single phase is involved
    if numel(unique(grains.phase)) > 1
      
      error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict EBSD data to a single phase.']);
      
    elseif numel(grains.phase) == 0
      
      varargout{1} = [];
      
    else
      
      varargout{1} = orientation(grains.meanRotation,get(grains,'CS'),get(grains,'SS'));
      
    end
    
  case {'rotation'}
    
    varargout{1} = grains.meanRotation;
    
    %   case {'mis2mean'}
    %
    %     mapping = any(grains.I_DG,1);
    %     [g,d] = find(grains.I_DG(:,mapping)');
    %
    %     o = get(grains,'rotations');
    %     m = grains.meanRotation(g);
    %     varargout{1} = orientation(inverse(o) .* m,get(grains,'CS'),get(grains,'CS'));
    %
    
  case 'i_vg'
    
    % vertices incident to a grain V x G
    [i,j,v] = find(grains.F);
    I_VF = sparse(v,i,1,size(grains.V,1),size(grains.I_FDext,1));
    I_VG = I_VF * (grains.I_FDext|grains.I_FDsub) * grains.I_DG;
    
    varargout{1} = I_VG>0;
    
  case 'i_vf'
    
    % vertices incident to a grain V x G
    [i,j,v] = find(grains.F);
    I_VF = sparse(v,i,1,size(grains.V,1),size(grains.I_FDext,1));    
    varargout{1} = I_VF>0;
    
  case lower(properties)
    
    varargout{1} = grains.(properties{find_option(properties,vname)});
        
  case lower(options)
    
    varargout{1} = grains.options.(options{find_option(options,vname)});
   
  case 'ebsd'
    
    varargout{1} = grains.EBSD;
    
  case 'mineral'
    
    varargout = cellfun(@(x) get(x,'mineral') ,get(grains.EBSD,'CSCell'),'uniformoutput',false);
    
    % overload from EBSD data
  case [lower(get(grains.EBSD));'cscell'; 'weight']
    
    varargout{1} = get(grains.EBSD,vname);
    
  otherwise
    
    if nargout, varargout{1} = properties; else disp(properties), end
    return
    
end


