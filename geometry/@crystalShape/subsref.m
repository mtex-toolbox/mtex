function varargout = subsref(cS,s)
%overloads subsref

switch s(1).type
  case '()'
    
    if isa(s(1).subs{1},'vector3d')
      
      cS = cS.subSet(s(1).subs{1});
            
    else
      F = reshape(cS.F,[],size(cS.V,2),size(cS.F,2));
    
      ind = subsref((1:size(cS.V,2)).',s(1));
    
      cS.V = cS.V(:,ind);
      shift = repmat(repelem(((1:length(ind)).' - ind)*size(cS.V,1),size(F,1),1),1,size(F,3));
      cS.F = reshape(F(:,ind,:),[],size(F,3)) + shift;
      
    end
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',cS,s(2:end));
    else
      varargout{1} = cS;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',cS,s);
      
end
end
