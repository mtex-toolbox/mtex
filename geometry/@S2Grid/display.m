function display(S2G)
% standard output

if length(S2G) == 1
	disp([inputname(1) ' = "S2Grid", ',...
		char(S2G),', ',char(option2str(S2G(1).options))]);
	if GridLength(S2G) < 20
		disp(['points: ',char(S2G.Grid)]);
	end
else
	disp([inputname(1) ' = ',int2str(length(S2G)),' x "S2Grid"']);
	for i = 1:length(S2G)
		disp([' ',char(S2G(i)),' ',option2str(S2G(i).options)]);
		if GridLength(S2G(i)) < 20
			disp(['points: ',char(S2G(i).Grid)]);
		end
	end
end
