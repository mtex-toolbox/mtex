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
  
    function s = size(dp,varargin)
    
      fn = fieldnames(dp.prop);
      
      if isempty(fn)
        s = size([],varargin{:});
      else
        s = size(dp.prop.(fn{1}),varargin{:});
      end
      
    end
      
    function l = length(dp)
      
      l = prod(size(dp)); %#ok<PSIZE>
      
    end
    
    function n = numel(varargin)
      
      n = 1;
      
    end
    
    % ----------------------------------------------------
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
    function varargout = subsref(dp,s)

      % use direct indexing
      if isa(s,'double') || isa(s,'logical')
        
        fn = fieldnames(dp.prop);
        for i = 1:numel(fn)
          dp.prop.(fn{i}) = dp.prop.(fn{i})(s);
        end
        
        varargout{1} = dp;
        return
        
      end
      
      % use indexing by struct      
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
          try
        
            varargout{1} = subsref(dp.prop,s(1));
        
          catch 
                
            [varargout{1:nargout}] = builtin('subsref',dp,s);
    
          end
      end
    end
      
               
    % --------------------------------------------------
    function dp = subsasgn(dp,s,value)
            
      switch s(1).type
  
        case '()'
      
          if numel(s)>1, value =  subsasgn(subsref(dp,s(1)),s(2:end),value); end
                         
          fn = fieldnames(dp.prop);
                                  
          if isempty(value)
            
            for i = 1:numel(fn)
              dp.prop.(fn{i}) = subsasgn(dp.prop.(fn{i}),s(1),[]);
            end
            
          else
            
            for i = 1:numel(fn)
              dp.prop.(fn{i}) = subsasgn(dp.prop.(fn{i}),s(1),value.prop.(fn{i}));
            end
            
          end
        otherwise
    
          dp.prop =  builtin('subsasgn',dp.prop,s,value);
      
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
    function c = char(dp)
      
      fn = fieldnames(dp.prop);
      if ~isempty(fn) && length(dp)<=20        
        d = zeros(length(dp),numel(fn));
        for j = 1:numel(fn)
          if isnumeric(dp.prop.(fn{j}))
            d(:,j) = vertcat(dp.prop.(fn{j}));
          elseif isa(dp.prop.(fn{j}),'quaternion')
            d(:,j) = angle(dp.prop.(fn{j})) / degree;
          end
        end
        c  = cprintf(d,'-Lc',fn,'-L',' ','-d','   ','-ic',true);
      else
        c  = cprintf(fn(:)','-L',' Properties: ','-d',', ','-ic',true);        
      end      
    end
    
    % -----------------------------------------------
    function display(dp)
      
      disp(' ');
      disp([inputname(1) ' = ' doclink('dynProp_index','dynProp') ...
        ' ' docmethods(inputname(1))]);

      fn = fieldnames(dp.prop);
      
      disp([' size: ' size2str(dp.prop.(fn{1}))])
      
      disp(char(dp))
            
    end
    
  end
  
end
