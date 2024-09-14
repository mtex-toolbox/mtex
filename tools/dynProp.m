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
        if isempty(varargin{k}), continue; end
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
        if size(dp.prop.(fn{i}),2)>1 && length(dp) == size(dp.prop.(fn{i}),1)
          dp.prop.(fn{i}) = dp.prop.(fn{i})(ind,:);
        else
          dp.prop.(fn{i}) = dp.prop.(fn{i})(ind);
        end
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
          if isfield(dp.prop,s(1).subs) 
            varargout{1} = subsref(dp.prop,s);
          else
            [varargout{1:nargout}] = builtin('subsref',dp,s);
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

              if size(dp.prop.(fn{i}),2)>1 && length(dp) == size(dp.prop.(fn{i}),1)
                s.subs = [s.subs, ':'];
              end
              
              dp.prop.(fn{i}) = subsasgn(dp.prop.(fn{i}),s(1),value.prop.(fn{i}));
              
            end
            
          end
        case '.'
          if isfield(dp.prop,s(1).subs)
            dp.prop =  builtin('subsasgn',dp.prop,s,value);
          else
            dp = builtin('subsasgn',dp,s,value);
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
      if isempty(fn)
        c = [];
        return;
      end

      numdP = length(dp.prop.(fn{1}));

      if ~isempty(fn) && numdP<=20
      
        numCustom = length(varargin)/2;
        fn = [varargin(1:2:end).'; fn];

        d = cell(numdP,length(fn));
        
        for i = 1:numCustom
          d(:,i) = prop2List(varargin{2*i});
        end
        
        for j = numCustom+1 : numel(fn)
          d(:,j) = prop2List(dp.prop.(fn{j}));
        end
              
        c  = cprintf(full(d),'-Lc',fn,'-L',' ','-d','   ','-ic',true);
      else
        c  = cprintf(fn(:)','-L',' <strong>Properties</strong>: ','-d',', ','-ic',true);
      end  
    
      function out = prop2List(prop)

        out = cell(size(prop,1),1);
        for k = 1:size(prop,1)
          if isa(prop,'quaternion')
            out{k} = char(prop(k),'Euler');
          elseif isa(prop,'vector3d')
            out{k} = ['(' xnum2str(prop(k).xyz,'delimiter',',') ')'];
          elseif isnumeric(prop) && isscalar(prop)
            out{k} = prop(k,:);
          elseif isnumeric(prop)
            out{k} = xnum2str(prop(k,:));
          elseif iscell(prop)
            out{k} = char(prop{k});
          else
            out{k} = char(prop(k,:));
          end
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
