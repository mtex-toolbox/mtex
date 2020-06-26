function display(T,varargin)
% standard output

displayClass(T,get_option(varargin,'name',inputname(1)));

% collect tensor properties
props = fieldnames(T.opt);
props = props(~strcmp(props,'name'));

propV = cellfun(@(prop) c2char(T.opt.(prop)),props,'UniformOutput',false);

% add size if greater one
if sum(size(T.M)>1) > T.rank
  props = ['size';props];
  propV = [size2str(T);propV];
end

% add rank
props{end+1} = 'rank'; 
propV{end+1} = [num2str(T.rank),' (' strrep(int2str(tensorSize(T)),'  ',' x ') ')'];

% add double convention
if T.doubleConvention
  props{end+1} = 'doubleConvention';
  propV{end+1} = 'true';
end

% collect symmetry
if isa(T.CS,'crystalSymmetry')
  props{end+1} = 'mineral'; 
  propV{end+1} = char(T.CS,'verbose');
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

if sum(size(T.M)>1) > T.rank || isempty(T.M), return;end

% display tensor coefficients
disp(' ');


b = ceil(log10(1./max(abs(T.M(:)))))+1;

if isfinite(b) && abs(b) > 1
   s = ([' *10^',num2str(-b)]);
else
  s = '';
end

if (T.rank == 4) && numel(T.M) == 3^4
  disp(['  tensor in Voigt matrix representation:' s])
  M = (tensor42(T.M,T.doubleConvention));
elseif (T.rank == 3) && numel(T.M) == 3^3
  disp(['  tensor in compact matrix form:' s])
  M = tensor32(T.M,T.doubleConvention);
else
  disp(s)
  M = T.M;
end

%make numbers nice
r = round(log(max(abs(T.M(:))))/log(10))-4;
if ~isinf(r) && ~isnan(r), M = round(10^(-r)*M).*10^(r);end


if isfinite(b) && abs(b) > 1
  M = M*10^b;
  M(abs(M)<eps) = 0;
end

cprintf(M,'-L',' ','-ic','|F');

end

function c = c2char(c)
if isnumeric(c)
  c = num2str(c);
elseif islogical(c)
  if c, c = 'true'; else c = 'false'; end
else
  c = char(c);
end
end
