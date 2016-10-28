function varargout = docmethods(obj)
% display all methods for a certain class

%
if nargout > 0 && ischar(obj)

  if evalin('base',['exist(''' obj ''',''var'')']) && ...
      getMTEXpref('mtexMethodsAdvise',true) && ...
      ~getMTEXpref('generatingHelpMode')

    varargout{1} = ['(<a href="matlab:docmethods(' obj ')">show methods</a>',...
      ', <a href="matlab:plot(' obj ')">plot</a>)'];

  else

    varargout{1} = ' ';

  end

else

  [~, fun] = methods(obj,'-full');
  fun = fun(:,4);

  if ischar(obj)
    classname = obj;
  else
    classname = class(obj);
  end

  for k=1:numel(fun)
    fun{k} = regexpsplit(fun{k},'\.');   
  end

  f  = cellfun(@(x) x{2},fun,'UniformOutput',false);
  [~,ndx] = sort(lower(f));
  f = f(ndx);
  c  = cellfun(@(x) x{1},fun(ndx),'UniformOutput',false);
  ds = cellfun(@(f,c) doclink([c '.' f],f),f,c,'UniformOutput',false);

  isInherited = ~strcmpi(c,classname);
  disp( formatedOutput(classname,ds(~isInherited),f(~isInherited)) );

  if any(isInherited)
    c = unique(c(isInherited));
    for k=1:numel(c)
      disp(['     Inherited from class <a href="matlab:docmethods(''' c{k} ''')">' c{k} '</a>']);
    end
    disp(' ')
  end

end

function s = formatedOutput(cl,ds,s)

m = cellfun('prodofsize',s);

offset = num2cell(max(m)+2-m);

ds = cellfun(@(s,n)  [s repmat(' ',1,n)],ds,offset,'UniformOutput',false);

s = [' ' ds{:}];

c = cumsum(cellfun('prodofsize',ds));
cmdsz = get(0,'CommandWindowSize');
n = fix((cmdsz(1)-1)./(max(m)+2));
for k = n*fix(numel(c)/n):-n:1
  s = [s(1:c(k)) char(10) s(c(k)+1:end)];
end

s = [char(10) 'Methods for class ' doclink([cl '/' cl],cl) ':' char(10) char(10) deblank(s) char(10)];
