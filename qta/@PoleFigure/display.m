function display(pf)
% standard output

disp(' ');
if isempty(pf(1).comment)
  %disp([inputname(1) ' = "PoleFigure", ',option2str(pf(1).options)]);
  disp([inputname(1) ' = "PoleFigure"']);
end

disp(char(pf));

%if ~isempty(pf(1).P_hat)
%	disp(['Fourrier coefficients, bandwidth: ',...
%  int2str(bandwidth(pf))]);
%end
