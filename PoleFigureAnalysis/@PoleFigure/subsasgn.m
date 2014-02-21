function pf = subsasgn(pf,s,b)
% overloads subsasgn

if ~isa(pf,'PoleFigure')
  pf = PoleFigure;
  pf.SS = b.SS;
end
 
switch s(1).type
 
  
  case '()'
  
    if numel(s)>1, b =  subsasgn(subsref(pf,s(1)),s(2:end),b); end
    
    if isa(s(1).subs{1},'cell') || ischar(s(1).subs{1}) || isa(s(1).subs{1},'Miller')
  
      ind = subsind(pf,s(1).subs);
  
      if isempty(b)
      
        pf.allR(ind) = [];
        pf.allH(ind) = [];
        pf.allI(ind) = [];
        pf.c(ind) = [];
                                
      else
      
        pf.allR(ind) = b.allR;
        pf.allH(ind) = b.allH;
        pf.allI(ind) = b.allI;
        pf.c(ind) = b.c;
        
      end
  
    else % set individuell intensities
      
      id = false(size(pf.intensities));
      id = subsasgn(id,s(1),true);
  
      cs = cumsum([0,cellfun('prodofsize',pf.allI)]);

      for k = 1:length(pf.allI)
  
        idi = id(cs(k)+1:cs(k+1));
      
        if isa(b,'PoleFigure')
          pf.allI{k}(idi) = b.allI{k};
          pf.allR{k}(idi) = b.allR{k};
        elseif isempty(b)
          pf.allI{k}(idi) = [];
          pf.allR{k}(idi) = [];
        else
          pf.allI{k}(idi) = b;
        end
      end
    end
  
  otherwise
    
    % maybe we can adress the PoleFigure object directly
    try %#ok<TRYNC>
      pf = builtin('subsasgn',pf,s,b);
      return
    end
    
    % maybe it is an option
    if pf.isOption(s(1).subs)
      pf = subsasgn@dynOption(pf,s,b);
    else % otherwise a property
      pf = subsasgn@dynProp(pf,s,b);
    end

end
end
