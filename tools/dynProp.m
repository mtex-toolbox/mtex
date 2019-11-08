classdef dynProp
  %class to add dynamic properties to a static class
  %   Detailed explanation goes here
  
  properties
    prop = struct    
  end
  
  methods
    
    function dp = dynProp(varargin)          
      
      dp.prop = struct(varargin{:});      
      
    end
      
    % ----------------------------------------------------
    
    function n = numArgumentsFromSubscript(varargin)
      n = 1;
    end
    
    function dp = cat(dim,varargin)
      
      dp = varargin{1};
      
      for k=1:numel(varargin)
        s(k) = varargin{k}.prop; %#ok<AGROW>
      end
      
      fn = fieldnames(varargin{1}.prop);
              
      for i = 1:numel(fn)                       
        dp.prop.(fn{i}) = cat(dim,s.(fn{i}));
      end
    
    end
  
    function dp = horzcat(varargin)
      
      dp = cat(2,varargin{:});
      
    end
    
    function dp = vertcat(varargin)
      
      dp = cat(1,varargin{:});
      
    end
    
    
    % --------------------------------------------------
  
    
    function b = isProperty(dp,fieldName)
      b = isfield(dp.prop,fieldName);
    end
    
    function dp = subSet(dp,ind)

      fn = fieldnames(dp.prop);
      for i = 1:numel(fn)
        dp.prop.(fn{i}) = dp.prop.(fn{i})(ind);
      end

    end

    
    function varargout = subsref(dp,s)

      switch s(1).type
        case '()'
  
          fn = fieldnames(dp.prop);
              
          for i = 1:numel(fn)
            dp.prop.(fn{i}) = subsref(dp.prop.(fn{i}),s(1));
          end
                
          if numel(s)>1
            [varargout{1:nargout}] = subsref(dp,s(2:end));
          else
            varargout{1} = dp;
          end
      
        case '.'
          if ismethod(dp,s(1).subs) || isprop(dp,s(1).subs)
            [varargout{1:nargout}] = builtin('subsref',dp,s);
          else
            varargout{1} = subsref(dp.prop,s);
          end
          
      end
    end
      
               
    % --------------------------------------------------
    function dp = subsasgn(dp,s,value)
            
      switch s(1).type
  
        case '()'
      
          if numel(s)>1, value =  subsasgn(subsref(dp,s(1)),s(2:end),value); end
                         
          if isempty(value)
          
            fn = fieldnames(dp.prop);
            for i = 1:numel(fn)
              dp.prop.(fn{i}) = subsasgn(dp.prop.(fn{i}),s(1),[]);
            end
            
          else
            
            fn = fieldnames(value.prop);
            for i = 1:numel(fn)
              if ~isfield(dp.prop,fn{i}), dp.prop.(fn{i})= zeros(size(dp));end
              dp.prop.(fn{i}) = subsasgn(dp.prop.(fn{i}),s(1),value.prop.(fn{i}));
            end
            
          end
        otherwise
    
          if isprop(dp,s.subs)
            dp = builtin('subsasgn',dp,s,value);
          else
            dp.prop =  builtin('subsasgn',dp.prop,s,value);
          end
      end      
    end
       
    % --------------------------------------------------
    function dp = set(dp,varargin)
      for i = 1:2:numel(varargin)        
        dp.prop.(varargin{i}) = varargin{i+1};
      end
    end
    
    function value = getProp(dp,name)
      value = dp.prop.(name);
    end
    
    function out = isProp(dp,name)
      out = isfield(dp.prop,name);
    end
    
    % -----------------------------------------------
    function c = char(dp,varargin)
      
      fn = fieldnames(dp.prop);
      fn_ext = [];
      
      if ~isempty(fn) && length(dp.prop.(fn{1}))<=20
        
        d = zeros(numel(dp.prop.(fn{1})),0);
        
        for i = 1:2:length(varargin)
          [propName,value] = prop2list(varargin{i:i+1});
          d = [d,value];%#ok<AGROW>
          fn_ext = [fn_ext,propName];%#ok<AGROW>
        end
        
        for j = 1:numel(fn)
          [propName,value] = prop2list(fn{j},vertcat(dp.prop.(fn{j})));
          fn_ext = [fn_ext,propName]; %#ok<AGROW>
          d = [d,value]; %#ok<AGROW>          
        end
        
        c  = cprintf(full(d),'-Lc',fn_ext,'-L',' ','-d','   ','-ic',true);
      else
        c  = cprintf(fn(:)','-L',' Properties: ','-d',', ','-ic',true);
      end  
      
      
      function [prop,value] = prop2list(prop,value)
        
        if isa(value,'quaternion')
          [w1,w2,w3,prop] = Euler(value);
          value = round([w1(:),w2(:),w3(:)]/degree);
        else
          prop = {prop};
          value = value(:);
        end 
        
      end
        
    end
    
    % -----------------------------------------------
    function display(dp,varargin)
      
      displayClass(dp,inputname(1),varargin{:});

      fn = fieldnames(dp.prop);
      
      disp([' size: ' size2str(dp.prop.(fn{1}))])
      
      disp(char(dp))
            
    end
    
  end
  
end
