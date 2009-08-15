function [g grains] = grainfun(FUN,grains,varargin)
% Apply function to each grain or to each grain and its corresponding ebsd data 
%
%% Syntax
%  g = grainfun(fun,grains)
%  g = grainfun(fun,grains,ebsd)
%
%
%% Input
%  fun      - function_handle
%  grains   - @grain object
%  ebsd     - @EBSD corresponding to grains
%
%% Options
%  UniformOutput - true/false
%  Property      - write uniformed value to given propertyname of grain-object
%
%% Example
%  tindex = grainfun( @(x) textureindex(calcODF(x)), ...
%             grains,ebsd,'UniformOutput',true);
%
%  grains = calcODF(grains,ebsd);
%  tindex = grainfun(@textureindex, grains,'ODF');
%
%% See also
% 


if nargin > 1
  
  hasebsd = 0; 
  uniform = true;
  if ~isempty(varargin)    
    hasebsd = find_type(varargin,'EBSD');
    if hasebsd
      uniform = false;
    end
  end
  
  uniform = get_option(varargin,'UniformOutput',uniform);
  
  if hasebsd
    ebsd = varargin{hasebsd};    
    [grains ebsd ids] = get(grains, ebsd);
    
    [s ndx] = sort([grains.id]);
            
    if ~isempty(grains)        
      if isa(FUN,'function_handle')
        g = cell(size(grains));
        ebsd = partition(ebsd, ids,'nooptions');
        
        progress(0,numel(ebsd))
        for k=1:numel(ebsd)          
          if abs(fix(k/numel(ebsd)*40)-fix((k-1)/numel(ebsd)*40))>0 ,
             progress(k,numel(ebsd)); end
           
          try           
            g{ndx(k)} = FUN(ebsd(k));
          catch
            g{ndx(k)} = NaN;
          end
        end
      else
        error('MTEX:grainfun:argChk' , ['Undefined function or variable ''' FUN '''']);
      end     
    end
  else    
    
    if nargin > 2 && isa(varargin{1},'char')
      switch varargin{1}       
        case fields(grains(1).properties)
           p = [grains.properties];
           grains = {p.(varargin{1})};
      end
    end    
    
    cl = ~iscell(grains);
    g = cell(size(grains));
    
    progress(0,length(grains))
    for k=1:length(grains)      
      if abs(fix(k/length(grains)*40)-fix((k-1)/length(grains)*40))>0 ,
         progress(k,length(grains));end
       
      if cl
        g{k} = FUN(grains(k));
      else
        g{k} = FUN(grains{k});
      end
    end
  end
else
  error('MTEX:grainfun:argChk' , 'wrong number of arguments');
end


cellclass = class(g{1});
ciscellclass = cellfun('isclass',g,cellclass);

if (uniform  || check_option(varargin,'property','char')) && all(ciscellclass(:))
  g = [g{:}];
end

if nargout > 1 && check_option(varargin,'property','char')    
	grains = set(grains,get_option(varargin,'property'),g); 
end


