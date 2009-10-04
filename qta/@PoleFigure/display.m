function display(pf,varargin)
% standard output

disp(' ');
h = 'Pole Figure Data';

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp(h);
disp(repmat('-',1,length(h)));

if isempty(pf(1).comment)
  %disp([inputname(1) ' = "PoleFigure", ',option2str(pf(1).options)]);
  disp([inputname(1) ' = "PoleFigure"']);
end

disp(char(pf));

%if ~isempty(pf(1).P_hat)
%	disp(['Fourrier coefficients, bandwidth: ',...
%  int2str(bandwidth(pf))]);
%end
