function display(cs,varargin)
% standard output

displayClass(cs,inputname(1));

disp(' ');

props = {}; propV = {};

% add mineral name if given
if ~isempty(cs.mineral)
  props{end+1} = 'mineral'; 
  propV{end+1} = cs.mineral;
end

if ~isempty(cs.color)
  props{end+1} = 'color'; 
  propV{end+1} = rgb2str(cs.color);
end

% add symmetry
props{end+1} = 'symmetry'; 
if cs.id>0
  propV{end+1} = [symmetry.pointGroups(cs.id).Inter];
else
  propV{end+1} = 'unkwown';
end

% add symmetry
props{end+1} = 'elements'; 
propV{end+1} = numSym(cs);



% add axis length
props{end+1} = 'a, b, c';
propV{end+1} = option2str(vec2cell(norm(cs.axes)));

% add axis angle
if cs.id < 12
  props{end+1} = 'alpha, beta, gamma';
  propV{end+1} = [num2str(cs.alpha./degree) mtexdegchar ', ' ...
    num2str(cs.beta./degree) mtexdegchar ', ' ...
    num2str(cs.gamma./degree) mtexdegchar];
end

% add reference frame
if ~cs.lattice.isEucledean
  props{end+1} = 'reference frame'; 
  propV{end+1} = option2str(cs.alignment);    
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

disp(' ');
