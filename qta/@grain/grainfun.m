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
    
    if any(strcmpi(foo , methods(ODF))) && nargin(['@ODF' filesep foo]) < 0
      options{end+1} = 'silent';
      res = get_option(varargin,'RESOLUTION',2.5*degree);

      [phase uphase] = get(grains,'phase');
      CS = get(grains,'CS');
      SS = get(grains,'SS');
      
      S3G = cell(size(uphase));
      for k=1:numel(uphase)      
        S3G{k} = SO3Grid(res,CS{k},SS{k});
      end        
      
      if find_type(options,'ODF')
        odf_pos = find(cellfun('isclass',options,'ODF'));
        assert(numel(odf_pos) == numel(uphase), 'if any additional ODF is specified, the number of ODFs must agree with the phases');
        
        for k=1:numel(odf_pos)
          odf_eval{k} = eval(options{odf_pos(k)},S3G{k},varargin{:});
        end
        options(odf_pos) = [];
      end      
    end
  end
  
  for k=1:nn
    if fix(k*nf) ~= fix((k-1)*nf)
       progress(k,nn);
    end
    
    options2 = options;
    if exist('S3G','var') && exist('phase','var') % pass a Grid if possible
      options2 =  [ 'SO3Grid', S3G(phase(k)), options2 ];
    end
    if exist('odf_eval','var') && exist('phase','var')
      options2 = [ 'evaluated',odf_eval(phase(k)),options2 ];
    end
    
    g{k} = feval(FUN,evar{k},options2{:});
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
