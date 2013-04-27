function sym = findsymmetry(name)
% search for specific symmetry

% import list of point groups
sl = SymList;
names = {sl.Schoen;sl.Inter;sl.System};

% search for point group
match = any(strcmp(name,names.'),2);

% if nothing found convert space to point group
if ~any(match) 
  match = any(strcmp(hms2point(name),names.'),2);
end

% take the last match
sym = find(match,1,'last'); 

% extract data
sym = sl(sym);
