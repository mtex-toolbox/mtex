function p = phaseColumn(g,phaseNr)
% the phase of every cell of a gridded map, numbered the way the file counts
% its phases, 0 for a cell that is not indexed or carries no measurement

p = zeros(size(g));

ok = ~isnan(g.phaseId);
p(ok) = phaseNr(g.phaseId(ok));

end
