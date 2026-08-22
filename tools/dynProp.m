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

      n  = length(dp);
      fn = fieldnames(dp.prop);
      for i = 1:numel(fn)
        v = dp.prop.(fn{i});
        k = nChannels(dp,v);
        if k > 1
          % index the objects and take every channel along. Flattening to
          % one row per object first makes this the same operation whether
          % the property is stored as N x k or, on a grid class, as
          % r x c x k - the result is a list either way, and a caller that
          % wants the map shape back reshapes (EBSDsquare/subGrid does).
          v = reshape(v,n,k);
          dp.prop.(fn{i}) = v(ind(:),:);
        else
          dp.prop.(fn{i}) = v(ind);
        end
      end

    end

    
    function varargout = subsref(dp,s)

      switch s(1).type
        case '()'
  
          fn = fieldnames(dp.prop);

          for i = 1:numel(fn)
            dp.prop.(fn{i}) = subsref(dp.prop.(fn{i}),...
              rowSubs(dp,s(1),dp.prop.(fn{i})));
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
              dp.prop.(fn{i}) = assignRows(dp,dp.prop.(fn{i}),s(1),[]);
            end

          else

            fn = fieldnames(value.prop);
            for i = 1:numel(fn)

              v = value.prop.(fn{i});

              if ~isfield(dp.prop,fn{i})
                % a property the target does not carry yet, sized from the
                % value - one plane per channel, behind the object's shape
                k = nChannels(value,v);
                if k > 1
                  dp.prop.(fn{i}) = zeros([objShape(dp) k]);
                else
                  dp.prop.(fn{i}) = zeros(size(dp));
                end
              end

              dp.prop.(fn{i}) = assignRows(dp,dp.prop.(fn{i}),s(1),v);

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

      numdP = numel(dp.prop.(fn{1}));

      if ~isempty(fn) && numdP<=20
      
        numCustom = length(varargin)/2;
        fn = [varargin(1:2:end).'; fn];

        d = cell(numdP,length(fn));
        
        for i = 1:numCustom
          d(:,i) = prop2List(varargin{2*i}(:));
        end
        
        for j = numCustom+1 : numel(fn)
          d(:,j) = prop2List(dp.prop.(fn{j})(:));
        end
              
        c  = cprintf(full(d),'-Lc',fn,'-L',' ','-d','   ','-ic',true);
      else
        c  = cprintf(fn(:)','-L',char(strong(" Properties") + ": "),'-d',', ','-ic',true);
      end  
    
      function out = prop2List(prop)

        out = cell(size(prop,1),1);
        for k = 1:size(prop,1)
          if isa(prop,'quaternion')
            out{k} = char(prop(k),'Euler');
          elseif isa(prop,'vector3d')
            out{k} = ['(' xnum2str(prop(k).xyz,'delimiter',',') ')'];
          elseif isa(prop,'SO3Fun')
            out{k} = xnum2str(mean(prop(k)));
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

% =========================================================================
function k = nChannels(dp,value)
% how many channels a property carries; 1 for an ordinary one
%
% A property holds one entry per object, or k of them. On a list that is an
% N x k matrix - a 5 diode forescatter image, say, or an RGB image. On a
% grid class, whose properties are stored as the (r x c) matrix of the map,
% the same image is r x c x k, one plane per channel. Either way the leading
% dimensions are the shape of the object and the channels are whatever is
% left over once the object count is divided out.
%
% length(dp) is the number of objects, not a matrix dimension: for the
% classes that matter here it resolves to phaseList/length, which returns
% size(phaseId,1) and so stays the pixel count even for a grid class. The
% size(value,1) == size(dp,1) test is what keeps a square map's ordinary
% (r x c) property from being read as c channels.

k = 1;

n = length(dp);
if n == 0 || isempty(value), return; end

m = numel(value) / n;
if m > 1 && m == round(m) && size(value,1) == size(dp,1), k = m; end

end

% =========================================================================
function sz = objShape(dp)
% the object's own shape, with the channel dimension to be appended behind it
%
% A column shaped object stores a multi channel property as n x k, not
% n x 1 x k, so its trailing singleton has to go before the channels are
% appended. A grid keeps both of its dimensions and takes r x c x k.

sz = size(dp);
if numel(sz) == 2 && sz(2) == 1, sz = sz(1); end

end

% =========================================================================
function target = assignRows(dp,target,s,v)
% assign v into the objects picked out by s, channels and all
%
% A multi channel property is flattened to one row per object first, so that
% a single linear or logical subscript addresses pixels rather than rows of
% the (r x c) matrix a grid class stores, and the shape is put back
% afterwards. Deleting removes objects, so there is no shape left to put
% back and the result stays a list.

k = nChannels(dp,target);

if k == 1
  target = subsasgn(target,s,v);
  return
end

shp    = size(target);
n      = length(dp);
target = reshape(target,n,k);

% the caller's subscript, resolved against the objects rather than against
% the storage, so that (i,j) and a linear index mean the same thing here
s.subs = {reshape(subsref(reshape(1:n,size(dp)),s),[],1), ':'};

if isempty(v)
  target = reshape(subsasgn(target,s,[]),[],k);
else
  target = reshape(subsasgn(target,s,reshape(v,[],k)),shp);
end

end

% =========================================================================
function s = rowSubs(dp,s,value)
% the subscript to index value with, given a subscript meant for the objects
%
% Built fresh from the caller's subscript for every property rather than
% appended to a shared one - accumulating into s adds a second ':' as soon
% as a second property is multi channel.
%
% Appending one ':' is right when the subscript already addresses the
% object's own dimensions: (ind) on an N x k list, (i,j) on an r x c x k
% grid. A single linear subscript into a grid would need the property
% flattened to one row per object instead - subSet does that, and @EBSD and
% @grain2d route all of their () indexing through it rather than through
% here.

if nChannels(dp,value) > 1, s.subs = [s.subs, ':']; end

end
