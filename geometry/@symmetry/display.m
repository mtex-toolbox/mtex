function display(s)
% standard output

% check whether crystal or specimen symmetry
if ~s.isCS
  
  disp(' ');
  disp([inputname(1) ' = ' s.pointGroup ' specimen ' doclink('symmetry_index','symmetry') ' ' docmethods(inputname(1))]);
  disp(' ');
  
  return
end


disp(' ');
disp([inputname(1) ' = crystal ' doclink('symmetry_index','symmetry') ' ' docmethods(inputname(1))]);

disp(' ');

props = {}; propV = {};

% add mineral name if given
if ~isempty(s.mineral)
  props{end+1} = 'mineral'; 
  propV{end+1} = s.mineral;
end

if ~isempty(s.color)
  props{end+1} = 'color'; 
  propV{end+1} = s.color;
end


% add symmetry
props{end+1} = 'symmetry'; 
propV{end+1} = [s.pointGroup ' (' s.laueGroup ')'];

% add axis length
if ~any(strcmp(s.laueGroup,{'m-3','m-3m'}))
  props{end+1} = 'a, b, c'; 
  propV{end+1} = option2str(vec2cell(get(s,'axesLength')));
end


% add axis angle
if any(strcmp(s.laueGroup,{'-1','2/m'}))
  props{end+1} = 'alpha, beta, gamma';
  angles = get(s,'axesAngle');
  propV{end+1} = [num2str(angles(1)) '°, ' num2str(angles(2)) '°, ' num2str(angles(3)) '°'];
end

% add reference frame
if any(strcmp(s.laueGroup,{'-1','2/m','-3m','-3','6/m','6/mmm'}))
  props{end+1} = 'reference frame'; 
  propV{end+1} = option2str(get(s,'convention'));    
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');



