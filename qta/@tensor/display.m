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

ss = size(T.M);
s = [h, ' (', 'size: ' int2str(ss), ')' ];
disp(s)

disp([ '  symmetry:  ' char(T.CS)])
disp([ '      rank:  ' num2str( T.rank)] )
disp(' ');

%if max(abs(imag(T.M)))<1e-12, T.M = real(T.M);end

T.M = round(1e10*T.M)*1e-10;

if numel(T.M) == prod(ss(1:T.rank));
  if T.rank == 4
    disp('  tensor in Voigt matrix representation')
    cprintf(tensor42(T.M),'-L','  ');
  else
    cprintf(T.M,'-L','  ','-ic','F');
  end
end
