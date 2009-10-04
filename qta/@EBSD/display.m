function display(ebsd,varargin)
% standard output

disp(' ');
h = 'Individuel Orientation Data';

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp(h);
disp(repmat('-',1,length(h)));

if numel(ebsd)>0 && ~isempty(ebsd(1).comment)
  disp([' file: ' ebsd(1).comment]);
end  

if numel(ebsd)>0 && ~isempty(fields(ebsd(1).options))
  disp([' properties: ',option2str(fields(ebsd(1).options))]);
end

if numel(ebsd)== 0, disp(' empty'); end 
for i = 1:numel(ebsd)
  disp([' ' char(ebsd(i))]);
end
