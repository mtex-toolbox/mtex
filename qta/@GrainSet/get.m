function varargout = get(grains,vname)
% return property of a GrainSet
%
%% Input
% grains - @GrainSet
%
%% Syntax
%  o = get(grains,'meanOrientation') - returns the mean orientation of grains
%  o = get(grains,'orientations')    - returns individual orientations of the 
%                                      EBSD data from which grains were
%                                      constructed.
%  m = get(grains,'mis2mean')        - returns the misorientation of the
%                                      EBSD data to the mean orientation of
%                                      each grain.
%  p = get(grains,'phase')           - returns the phase index of grains
%  A = get(grains,'A_D')             - returns the adjacency matrix of neighbored
%                                      EBSD measurments.
%  I = get(grains,'I_DG')            - returns the incidence matrix ebsd measurement
%                                      incident to grain.
%  s = get(grains,'CS')              - returns the first indexed crystal symmetry
%                                      of the grains.
%  p = get(grains,'mad')             - returns the MAD property of the EBSD data, if MAD is a 
%                                      property of EBSD data from which the
%                                      grains were constructed.
%
%% Input
%  grains - @GrainSet
%
%% Output
%  o,m - @orientation
%  s - @symmetry
%  A,I - sparse matrix
%  p - double
%
%% See also
% EBSD/set

properties = get_obj_fields(grains,'GrainSet');
options    = fieldnames(grains.options);

if nargin == 1
  vnames = [properties;options;{'mean';'meanorientation';'orientations';'mineral';'minerals'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end

switch lower(vname)
  
  case  {'id', 'grain id', 'grain_id'}
    
    [varargout{1},~] = find(grains.I_DG.');
  
  case {'mean','meanorientation','orientation'}
    
    % check only a single phase is involved
    if numel(unique(grains.phase)) > 1
      
      error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict EBSD data to a single phase.']);
      
    elseif numel(grains.phase) == 0
      
      varargout{1} = [];
      
    else
      
      CS = get(grains,'CSCell');
      varargout{1} = orientation(grains.meanRotation,CS{grains.phase(1)},get(grains,'SS'));
      
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
    [i,j,v] = find(double(grains.F));
    I_VF = sparse(v,i,1,double(size(grains.V,1)),double(size(grains.I_FDext,1)));
    I_VG = I_VF * (grains.I_FDext|grains.I_FDsub) * grains.I_DG;
    
    varargout{1} = I_VG>0;
    
  case 'i_vf'
    
    % vertices incident to a grain V x G
    [i,j,v] = find(double(grains.F));
    I_VF = sparse(v,i,1,size(grains.V,1),size(grains.I_FDext,1));    
    varargout{1} = I_VF>0;
    
  case 'i_fg'
    
    I_FD = grains.I_FDext | grains.I_FDsub;
    varargout{1} = I_FD*double(grains.I_DG);    
    
  case 'phase'
    
    phaseMap = get(grains,'phaseMap');
    varargout{1} = phaseMap(grains.phase);
    
  case 'phases'
    
    varargout{1} = get(grains,'phaseMap');
    
  case lower(properties)
    
    varargout{1} = grains.(properties{find_option(properties,vname)});
        
  case lower(options)
    
    varargout{1} = grains.options.(options{find_option(options,vname)});
   
  case 'ebsd'
    
    varargout{1} = grains.EBSD;
    
    
    % overload from EBSD data
  case [lower(get(grains.EBSD));'cscell'; 'weight']
    
    varargout{1} = get(grains.EBSD,vname);
    
  otherwise
    
    error(['Unknown Property "' vname '" in class GrainSet']);
    
end


