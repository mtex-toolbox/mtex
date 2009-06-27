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
%             grains,ebsd,'UniformOutput',true)
%
%% See also
% 


if nargin > 1  
  if ~isempty(varargin)    
    hasebsd = find_type(varargin,'EBSD');
    uniform = false;
  else
    hasebsd = 0; 
    uniform = true;
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
        for k=1:numel(ebsd)
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
    for k=1:length(grains)
      g{k} = FUN(grains(k));
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


