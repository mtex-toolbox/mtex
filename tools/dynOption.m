classdef dynOption
  %class to add dynamic options to a static class
  %   Detailed explanation goes here
  
  properties
    opt = struct    
  end
  
  methods
    
    % ------------------------------------------
    function dOpt = dynOption(varargin)          
      
      if nargin==1 && isa(varargin{1},'dynOption')
        dOpt.opt = varargin{1}.opt;
      else
        dOpt.opt = struct(varargin{:});
      end
      
    end
    
    % -----------------------------------------
    function varargout = subsref(dOpt,s)
      
      try
        [varargout{1:nargout}] = builtin('subsref',dOpt,s);
      catch 
        for i = 1:numel(dOpt)
          varargout{i} = subsref(dOpt(i).opt,s);
        end        
      end      
    end
    
    % -------------------------------------------
    function dOpt = subsasgn(dOpt,s,value)
      
      dOpt.opt = subsasgn(dOpt.opt,s,value);
      
    end
       
    % -------------------------------------------
    function dOpt = set(dOpt,varargin)
      for i = 1:2:numel(varargin)        
        dOpt.opt.(varargin{i}) = varargin{i+1};
      end
    end
    
    % -------------------------------------------
    function value = getOption(dOpt,name)
      value = dOpt.opt.(name);
    end
    
    % -------------------------------------------
    function out = isOption(dOpt,name)
      out = isfield(dOpt.opt,name);
    end
    
    % --------------------------------------------
    function addOption(dOpt,name)
      for i = 1:numel(dOpt)
        dOpt.opt.(name) = [];
      end
    end

    % -------------------------------------------------------
    function c = char(dOpt,varargin)
      
      c = {};
      names = fieldnames(dOpt.opt);
      for i = 1:length(names)
        
        fn = names{i};
        switch class(dOpt.opt.(fn))
          case 'double'
            s = xnum2str(dOpt.opt.(fn));
          case 'logical'
            if dOpt.opt.(fn)
              s = 'true';
            else
              s = 'false';
            end
          otherwise
            s = char(dOpt.opt.(fn),varargin{:});
        end
        c = [c,{[' ' fn ': ' s]}]; %#ok<AGROW>
      end
      
      c = strvcat(c{:});
      
    end

    % ------------------------------------------------------
    function display(dOpt)
      % standard output

      disp(' ');
      disp([inputname(1) ' = ' doclink('dynOption_index','dynOption') ...
        ' ' docmethods(inputname(1))]);

      disp(char(dOpt));
  
    end    
  end
  
end
