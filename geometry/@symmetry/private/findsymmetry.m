function sym = findsymmetry(name)
% search for specific symmetry

sl = SymList;

names = {sl.Schoen;sl.Inter;sl.Rot;sl.System};
match = any(strcmp(name,names.'),2);

sym = find(match,1,'last'); 

if isempty(sym)
	error('symmetry "%s" not found',name);
end

sym = sl(sym);
