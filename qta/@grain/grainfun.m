function g = grainfun(FUN,grains,varargin)
% Apply function to each grain or to each grain and its corresponding ebsd data 
%
%% Syntax
%  g = grainfun(fun,grains)
%  g = grainfun(fun,grains,ebsd)
%
%  g = grainfun('phase',grains,ebsd)
%
%% Input
%  fun      - function_handle
%  grains   - @grain object
%  ebsd     - @EBSD corresponding to grains
%
%% Options
%  UniformOutput - true/false
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
    if hasebsd
      uniform = get_option(varargin,'UniformOutput',false);
      ebsd = varargin{hasebsd};    

      [grains ebsd ids] = get(grains, ebsd);
      
      if ~isempty(grains)        
        if isa(FUN,'function_handle')
          g = cell(size(grains));
          ebsd = partition(ebsd, ids,'nooptions');
          for k=1:numel(ebsd)
            try           
              g{k} = FUN(ebsd(k));
            catch
              g{k} = NaN;
            end
          end
        elseif strcmpi(FUN,'phase')
          phase = get(ebsd,'phase');
          csz = cumsum([0 sampleSize(ebsd)]);
          gid = [grains.id];
            g = zeros(size(grains));
          for k=1:length(phase)
            g(ismember(gid,ids(csz(k)+1:csz(k+1)))) = phase(k);
          end
          return
        else
          error('grainfun:argChk' , ['Undefined function or variable ''' FUN '''']);
        end     
        
        cellclass = class(g{1});
        ciscellclass = cellfun('isclass',g,cellclass);

        if uniform & all(ciscellclass(:))  
          g = [g{:}];
          % g = cell2mat(g);
        end
      end
      return
    end   
  end
    
  for k=1:length(grains)
    g{k} = FUN(grains(k));
  end
  
  if get_option(varargin,'UniformOutput',true)
    g = [g{:}];
  end 
end

