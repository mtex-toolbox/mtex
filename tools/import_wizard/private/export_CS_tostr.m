function str = export_CS_tostr(cs)


if numel(cs) > 1
  str = '{...';
else 
  str = '';
end

for i=1:numel(cs)
  
  options = {};
  if isempty(cs{i})
    
    t = 'symmetry()';
    
  elseif ischar(cs{i});
    
    t = ['''' cs{i} ''''];
    
  else
      
    [c,angle] = get_axisangel(cs{i});
    
    % for non cubic symmetries
    if ~any(strcmp(get(cs{i},'Laue'),{'m-3','m-3m'}))
      options = [options {c}]; %#ok<AGROW>
    end
  
    % for triclinic and monoclinic get angles
    if any(strcmp(get(cs{i},'Laue'),{'-1','2/m'}))
      options = [options {[n2s([angle{:}]),'*degree']}]; %#ok<AGROW>
    end
    
    options = [options get(cs{i},'alignment')]; %#ok<AGROW>
    
    mineral = get(cs{i},'mineral');
    if ~isempty(mineral)
      options = [options,{'mineral',mineral}];  %#ok<AGROW>
    end
    
    color = get(cs{i},'color');
    if ~isempty(color)
      options = [options,{'color',color}];  %#ok<AGROW>
    end
  
    t = strcat('symmetry(''', get(cs{i},'name'),'''',option2str(options,'quoted'),')');
  end
  
  if numel(cs) > 1
    str = [str; {t} ]; %#ok<AGROW>
    if i == numel(cs)
      str{end} = [ str{end} '}'];
    else
      str{end} = [ str{end} ',...'];
    end
  else
    str = [str t]; %#ok<AGROW>
  end
end


%%
function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
