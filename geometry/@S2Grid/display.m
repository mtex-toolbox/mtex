function display(S2G)
% standard output

disp(' ');
if length(S2G) == 1
	disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ', points: ',...
		char(S2G),', ',char(option2str(S2G(1).options))]);
else
  s = size(S2G);
	disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ...
    ' (' int2str(s(1)) 'x' int2str(s(2)) ')']);
	for i = 1:length(S2G)
		disp(['  points: ',char(S2G(i)),' ',option2str(S2G(i).options)]);
	end
end
disp(' ');
