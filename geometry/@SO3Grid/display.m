function display(N)
% standard output

disp([inputname(1) ' = "SO3Grid"']);
if length(N) == 1
	disp(['Symmetry: ',char(N.CS),' - ',char(N.SS)]);
	disp(['Grid    : ',char(N)]);
else
	disp(['Symmetry: ',char(N(1).CS),' - ',char(N(1).SS)]);
	for i = 1:length(N)
		disp(['Grid ',int2str(i),'  : ',char(N(i))]);
	end
end
