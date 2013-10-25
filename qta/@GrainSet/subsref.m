function varargout = subsref(grains,s)
% access subsets of a GrainSet
%
% Syntax
%   grains(1:10)          % the 10 first grains of a GrainSet
%   grains('Fe')          % only Fe grains
%   grains( ~grains('fe') ) % all grains but Fe
%                           logical array with size of the complete
%                           GrainSet


% called with direct indexing
if isa(s,'double') || isa(s,'logical')
  
  ng = size(grains.I_DG,2);
  % ignore empty grains
  mapping = find(any(grains.I_DG,1));
  mapping = mapping(s);
  
  D = sparse(mapping,mapping,1,ng,ng);
  old_D = any(grains.I_DG,2);
  
  grains.I_DG = grains.I_DG*D;
%   grains.A_G  = grains.A_G*D;
  grains.meanRotation = grains.meanRotation(s);
%   grains.gphase = grains.gphase(s);
    
  D = double(diag(any(grains.I_DG,2)));
  
  grains.A_Db = grains.A_Db*D;
  grains.A_Do = grains.A_Do*D;
  grains.I_FDext = grains.I_FDext*D;
  grains.I_FDint = grains.I_FDint*D;

  ebsd_subs = nonzeros(cumsum(old_D) .* any(grains.I_DG,2));
  grains.ebsd = subsref(grains.ebsd,ebsd_subs);
  
  D = any(grains.I_FDext | grains.I_FDint,2);
  grains.F(~D,:) = 0;
  
  [~,~,v] = find(double(grains.F));
  D = sparse(v,1,1,size(grains.V,1),1)>0;
  grains.V(~D,:) = 0;
  
  varargout{1} = grains;
  return;
  
end

if strcmp(s(1).type,'()')
  
  if check_option(s(1).subs,'sort')
    
    varargout{1} = subsref(grains,get_option(s(1).subs,'sort'));
    
  else
    
    ind = subsind(grains,s(1).subs);
    varargout{1} = subsref(grains,ind);
    
  end
  
elseif strcmp(s(1).type,'.')
  
  % maybe reference to a dynamic option
  try %#ok<TRYNC>
    [varargout{1:nargout}] = subsref@dynOption(grains,s);
    return
  end
  
  % maybe reference to a dynamic property
  try %#ok<TRYNC>
    [varargout{1:nargout}] = subsref@dynProp(grains,s);
    return
  end
  
  % maybe reference to a normal property
  [varargout{1:nargout}] = builtin('subsref',grains,s);
  
end

% is there something more to do?
if numel(s)>1
  varargout{1} = subsref(varargout{1},s(2:end));
  return
end

