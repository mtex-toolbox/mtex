function varargout = subsref(cS,s)
%overloads subsref

switch s(1).type
  case '()'
    
    if isa(s(1).subs{1},'vector3d')
      
      N = cS.N(:);
      if cS.habitus >0
        N = N ./ ((abs(N.h) * cS.extension(1)).^cS.habitus + ...
          (abs(N.k) * cS.extension(2)).^cS.habitus + ...
          (abs(N.l) * cS.extension(3)).^cS.habitus).^(1/cS.habitus);
      end
      N = unique(N.symmetrise,'noSymmetry');
      
      ind = any(angle_outer(N,s(1).subs{1},'noSymmetry')<1*degree,2);
      
      F = reshape(cS.F,[],size(cS.V,2),size(cS.F,2));
      cS.F = reshape(F(ind,:,:),[],size(F,3));
      
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
