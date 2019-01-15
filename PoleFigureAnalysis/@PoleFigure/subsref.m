function varargout = subsref(pf,s)
% overide polefigure() and polefigure{}

if any(strcmp(s(1).type,{'()','{}'}))
    
  if strcmp(s(1).type,'{}') || iscell(s(1).subs{1}) || ...
      (ischar(s(1).subs{1}) && ~strcmp(s(1).subs{1},':')) || isa(s(1).subs{1},'Miller')
  
    pf = pf.select(s(1).subs);
       
  else
    
    id = false(size(pf.intensities));
    
    if isa(s(1).subs{1},'vector3d')
      id(find(pf.r,s(1).subs{1}))=true;
    else      
      id = subsasgn(id,s(1),true);
    end
  
    cs = cumsum([0,cellfun('prodofsize',pf.allI)]);

    for k = 1:length(pf.allI)
  
      idi = id(cs(k)+1:cs(k+1));
      
      pf.allI{k} = pf.allI{k}(idi);
      pf.allR{k} = pf.allR{k}(idi);
    end
  end
  
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = pf;
    return
  end
end  

% maybe reference to a dynamic property
try %#ok<TRYNC>
  [varargout{1:nargout}] = subsref@dynProp(pf,s);
  return
end

% maybe reference to a dynamic option
try %#ok<TRYNC>
  [varargout{1:nargout}] = subsref@dynOption(pf,s);
  return
end

end
