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
cprintf(propV,'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');

%if max(abs(imag(T.M)))<1e-12, T.M = real(T.M);end

% make numbers nice
r = round(log(max(abs(T.M(:))))/log(10))-4;
T.M = round(10^(-r)*T.M).*10^(r);

% display tensor coefficients
if numel(T.M) == prod(ss(1:T.rank));
  if (T.rank == 4) && numel(T.M) == 3^4
    disp('  tensor in Voigt matrix representation')
    cprintf(tensor42(T.M),'-L','  ','-ic','F');
  elseif ndims(T.M) == 2
    cprintf(T.M,'-L','  ','-ic','F');
  end
end
