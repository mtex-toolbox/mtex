function display(N)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('SO3Grid_index','SO3Grid')]);
if length(N) == 1
	disp(['  symmetry: ',char(N.CS),' - ',char(N.SS)]);
	disp(['  grid    : ',char(N)]);
else
	disp(['  symmetry: ',char(N(1).CS),' - ',char(N(1).SS)]);
	for i = 1:length(N)
		disp(['  grid ',int2str(i),'  : ',char(N(i))]);
	end
end
disp(' ');
