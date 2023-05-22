function varargout = subsref(grains,s)
% implements grains(1:3)
%
% Syntax
%   grains(1:10)            % the 10 first grains
%   grains('Fe')            % only Fe grains
%   grains('id',5)          % give the grain with id 5 
%   grains(5)               % give the 5th grain in the list
%   grains( ~grains('fe') ) % all grains but Fe
%   grains(cond)        
%
% Input
%  grains - @grain2d
%  cond   - logical array with same size as grains
%


% some special cases to speed things up
if strcmp(s(1).type,'()') && ...
    length(s)>1 && strcmp(s(2).type,'.') && strcmp(s(2).subs,'meanOrientation')
  
  if strcmp(s(1).type,'{}')
    ind = grains.id2ind(s(1).subs{1});
  else
    ind = subsind(grains,s(1).subs);
  end
  
  phId = unique(grains.phaseId(ind));

  if length(phId) > 1
    error('MTEX:MultiplePhases',['\n' ...
      '----------------------------------------------------------------\n'...
      'Your variable contains the phases: ' ...
      grains.mineralList{phId(1)} ', ' grains.mineralList{phId(2)} '\n\n' ...
      'However, you are executing a command that is only permitted for a single phase!\n\n' ...
      'Please read the chapter ' doclink('EBSDSelect','"select EBSD data"')  ...
      ' for how to restrict grains to a single phase.\n' ...
      '----------------------------------------------------------------\n']);
  end
  if isempty(ind)
    ori = orientation;
  else
    ori = orientation(grains.prop.meanRotation(ind),grains.CSList{phId});
  end
    
  if numel(s)>2
    [varargout{1:nargout}] = builtin('subsref',ori,s(3:end));
  else
    varargout{1} = ori;
  end
  return
end



if strcmp(s(1).type,'()') || strcmp(s(1).type,'{}')
  
  if strcmp(s(1).type,'{}')
    ind = grains.id2ind(s(1).subs{1});
  else
    ind = subsind(grains,s(1).subs);
  end
  
  
  grains = subSet(grains,ind);
 
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = grains;
    return
  end
end

% maybe reference to a dynamic property
if isProperty(grains,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(grains,s);
  
else
  
  [varargout{1:nargout}] = builtin('subsref',grains,s);
  
end

end
