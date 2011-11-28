function display(T,varargin)
% standard output

disp(' ');

% collect top line
h = doclink('tensor_index','tensor');
if hasProperty(T,'name'), h = [get(T,'name'),' ',h];end

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

ss = size(T);
s = [h, ' (', 'size: ' int2str(ss), ')' ];

% display top line
disp(s)

% collect tensor properties
props = fieldnames(T.properties);
props = props(~strcmp(props,'name'));
propV = cellfun(@(prop) char(T.properties.(prop)),props,'UniformOutput',false);

% add rank
props{end+1} = 'rank'; 
propV{end+1} = T.rank;

% collect symmetry
if numel(T.CS) > 1 || ~all(1==norm(get(T.CS,'axis')))
  props{end+1} = 'mineral'; 
  propV{end+1} = char(T.CS,'verbose');
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

if numel(T.M) > prod(ss(1:T.rank)), return;end

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
  M = (tensor42(T.M));
elseif (T.rank == 3) && numel(T.M) == 3^3
  disp(['  tensor in compact matrix form:' s])
  M = tensor32(T.M,isfield(T,'doubleconvention'));
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

  





