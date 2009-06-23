function display(grains)
% standart output

disp(' ')
if ~isempty(grains(1).comment)
  str = grains(1).comment;
else
  str = [inputname(1),' = grain data '];
end
disp(str);
disp(repmat('-', size(str)))
if ~isempty(grains) 
  checksums = dec2hex(unique([grains.checksum]));  
  checksums = strcat(' grain_id', cellstr(checksums) ,',');
  disp([ checksums{:}]);
  
  if ~isempty(fields(grains(1).properties))
    disp([' properties: ',option2str(fields(grains(1).properties))]);
  end
end

disp([' size: ' num2str(size(grains,1)) ' x ' num2str(size(grains,2))])
