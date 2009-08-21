function [g grains] = grainfun(FUN,grains,varargin)
% Apply function to each grain or to each grain and its corresponding ebsd data 
%
%% Syntax
%  g = grainfun(fun,grains)
%  g = grainfun(fun,grains,ebsd)
%  g = grainfun(fun,grains,'field')
%
%
%% Input
%  fun      - function_handle
%  grains   - @grain object
%  ebsd     - @EBSD corresponding to grains
%  field    - property of a grain
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


if nargin < 2,  
  error('MTEX:grainfun:argChk' , 'wrong number of arguments');
end

g = cell(size(grains));

uniform = true;
hasebsd = find_type(varargin,'EBSD');
if ~isempty(hasebsd), uniform = false; end

uniform = get_option(varargin,'UniformOutput',uniform);
property = get_option(varargin,'Property',[],'char');    
options = delete_option(varargin,{'UniformOutput','property'},1);

nn = numel(grains); nf = 40/nn;
progress(0,nn);  

if hasebsd
  ebsd = varargin{hasebsd};
  options(find_type(options,'EBSD')) = [];
  
  [grains ebsd ids] = link(grains, ebsd);
  [s ndx] = sort([grains.id]);
          
  if ~isempty(grains)        
    if isa(FUN,'function_handle')
      ebsd = partition(ebsd, ids,'nooptions');
      
      for k=1:nn
        if fix(k*nf) ~= fix((k-1)*nf)
          progress(k,nn);
        end
         
        try           
          g{ndx(k)} = feval(FUN,ebsd(k),options{:});
        catch
          g{ndx(k)} = NaN;
        end
      end
    else
      error('MTEX:grainfun:argChk' , ['Undefined function or variable ''' FUN '''']);
    end     
  end
else  
  evar = num2cell(grains);
  
  %maybe we want do access a property
  if numel(options)>0 && isa(options{1},'char')
    try evar = get(grains,options{1}); options(1) = []; catch, end 
  end
  
  % odf warper
  isodf = all(cellfun('isclass', evar, 'ODF'));
  if isodf
    foo = FUN;
    if isa(foo,'function_handle'), foo = func2str(foo);  end
    
    if any(strcmpi(foo , methods(ODF))) && nargin(['@ODF\' foo]) < 0
      options{end+1} = 'silent';
      res = get_option(varargin,'RESOLUTION',2.5*degree);

      ph = get(grains,'phase');
      [uph m ph] = unique(ph);
      S3G = cell(size(uph));
      for k=1:numel(uph)      
        rp = find( ph == k,1,'first');
        pCS = get(grains(rp),'CS');
        pSS = get(grains(rp),'SS');
        S3G{k} = SO3Grid(res,pCS{:},pSS{:});
      end   
    end
  end
  
  for k=1:nn
    if fix(k*nf) ~= fix((k-1)*nf)
       progress(k,nn);
    end
     
    if exist('S3G','var') && exist('ph','var') % pass a Grid if possible
      g{k} = feval(FUN,evar{k},options{:},'SO3Grid',S3G{ph(k)});
    else
      g{k} = feval(FUN,evar{k},options{:});
    end
  end
end

if nargout > 1 && ~isempty(property)
	grains = set(grains,property,g); 
end

cellclass = class(g{1});
ciscellclass = cellfun('isclass',g,cellclass);
if uniform && all(ciscellclass(:))
  g = [g{:}];
end