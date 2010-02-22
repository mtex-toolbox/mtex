function display(grains,varargin)
% standart output

disp(' ');
h = doclink('grain_index','grain');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if ~isempty(grains)
  if ~isempty(grains(1).comment)
     h = [h, ' (' grains(1).comment ')'];
  end
end
  disp(h)

if ~isempty(grains) 
  checksums = dec2hex(unique([grains.checksum]));  
  checksums = strcat('  grain_id', cellstr(checksums) ,',');
  disp([ checksums{:}]);
  if ~isempty(fields(grains(1).properties))
    disp(['  properties: ',option2str(fields(grains(1).properties))]);
  end
end


disp(['  size: ' num2str(size(grains,1)) ' x ' num2str(size(grains,2))])
disp(' ');