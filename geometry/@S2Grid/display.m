function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ']);
disp(' ');
disp('  S2Grid:'); 
for i = 1:length(S2G)
		disp(['   (', num2str(i),') ',char(S2G(i)),' ',option2str(S2G(i).options)]);
		if GridLength(S2G(i)) < 20
			disp(['      points: ',char(S2G(i).Grid)]);
		end
end
disp(' ')