function display(p,varargin)

disp(' ');
h = doclink('polygon_index','polygon');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;  

disp(h)

disp(['  size: ' num2str(size(p,1)) ' x ' num2str(size(p,2))])

disp(' ');