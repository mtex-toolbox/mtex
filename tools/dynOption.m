classdef dynOption
  %class to add dynamic options to a static class
  %   Detailed explanation goes here
  
  properties
    opt = struct    
  end
  
  methods
    
    % ------------------------------------------
    function dOpt = dynOption(varargin)          
      
      if nargin == 0
        return
      elseif nargin==1 && isa(varargin{1},'dynOption')
        dOpt.opt = varargin{1}.opt;
      else
        dOpt.opt = struct(varargin{:});
      end
      
    end
    
    % -----------------------------------------
%     function varargout = subsref(dOpt,s)
%       
%       
%       try
%         varargout = cell(1,numel(dOpt));
%         for i = 1:numel(dOpt)
%           varargout{i} = subsref(dOpt(i).opt,s);
%         end
%       catch
%         [varargout{1:nargout}] = builtin('subsref',dOpt,s);
%       end      
%     end
    
    % -------------------------------------------
    %function varargout = subsasgn(dOpt,s,value)

    %  try
    %    [varargout{1:nargout}] = builtin('subsasgn',dOpt,s,value);
    %  catch        
    %    dOp.opt = subsasgn(dOpt.opt,s,value);
    %    varargout{1} = dOpt;
    %  end
    %end
       
    % -------------------------------------------
    function dOpt = setOption(dOpt,varargin)
      for i = 1:2:numel(varargin) 
        for j = 1:numel(dOpt)
          dOpt(j).opt.(varargin{i}) = varargin{i+1};
        end
      end
    end
        
    % -------------------------------------------
    function varargout = getOption(dOpt,name)
      for j = 1:numel(dOpt)
        varargout{j} = dOpt(j).opt.(name);
      end
    end
    
    % -------------------------------------------
    function out = isOption(dOpt,name)
      out = isfield(dOpt.opt,name);
    end
    
    % --------------------------------------------
    function dOpt = addOption(dOpt,name,value)
      if nargin == 2
        dOpt.opt.(name) = [];
      else
        dOpt.opt.(name) = value;
      end
    end
    
    % --------------------------------------------
    function dOpt = rmOption(dOpt,varargin)
      for i = 1:numel(varargin)
        if isfield(dOpt.opt,varargin{i})
          dOpt.opt = rmfield(dOpt.opt,varargin{i});
        end
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
            if numel(dOpt.opt.(fn)) < 20
              s = xnum2str(dOpt.opt.(fn));
            else
              s = [size2str(dOpt.opt.(fn)) ' double'];
            end
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
    function display(dOpt,varargin)
      % standard output

      displayClass(dOpt,inputname(1),varargin{:});
      
      disp(char(dOpt));
  
    end    
  end
  
end
