function display(T,varargin)
% standard output

disp(' ');
h = doclink('tensor_index','tensor');
if ~isempty(T.name), h = [T.name,' - ',h];end

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

s = [h, ' (', 'size: ' int2str(size(T.M)), ')' ];
disp(s)

disp([ '  symmetry:  ' char(T.CS)])
disp([ '      rank:  ' num2str( T.rank)] )
disp(' ');

if ndims(T.M) == T.rank
  if T.rank == 4
    disp('  tensor in Voigt matrix representation')
    cprintf(tensor42(T.M),'-L','  ');
  else
    cprintf(T.M,'-L','  ');
  end
end
