function display(s,varargin)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('crystalSymmetry_index','crystalSymmetry') ' ' docmethods(inputname(1))]);

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

fn = fieldnames(s.opt);
for i = 1:length(fn)
  props{end+1} = fn{i}; 
  propV{end+1} = s.opt.(fn{i});  
end


% add symmetry
props{end+1} = 'symmetry'; 
if s.id>0
  propV{end+1} = [symmetry.pointGroups(s.id).Inter];
else
  propV{end+1} = 'unkwown';
end

% add axis length
props{end+1} = 'a, b, c';
propV{end+1} = option2str(vec2cell(norm(s.axes)));

% add axis angle
if s.id < 12
  props{end+1} = 'alpha, beta, gamma';
  propV{end+1} = [num2str(s.alpha./degree) '°, ' num2str(s.beta./degree) '°, ' num2str(s.gamma./degree) '°'];
end

% add reference frame
if any(strcmp(s.lattice,{'triclinic','monoclinic','trigonal','hexagonal'}))
  props{end+1} = 'reference frame'; 
  propV{end+1} = option2str(s.alignment);    
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');
