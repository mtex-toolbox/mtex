function frameAssigned(what)
% the note ori.CS = cs leaves at the line that wrote it
%
% Assigning a frame keeps the numbers and restates which frame they were
% always in. Moving the data from one frame into another is
% <orientation.transformReferenceFrame.html |transformReferenceFrame|>, and
% the two read alike at a glance - so a line somebody wrote is told once.
%
% Reached only from @orientation/subsasgn, so MTEX writing a frame inside
% its own methods never gets here. What is left to tell apart is another
% MTEX file assigning through an object, which also means the first thing.

st = dbstack('-completenames');

% st(1) is this function and st(2) the subsasgn it was called from; the rest
% of the assignment machinery is MATLAB's, not anybody's code
k = 3;
while k <= numel(st) && ...
    (endsWith(st(k).name,'subsasgn') || endsWith(st(k).name,'subsref'))
  k = k + 1;
end

if k > numel(st) || startsWith(st(k).file,mtex_path), return; end

mtexWarnOnce('MTEX:orientation:frameAssigned',...
  ['Assigning %s restates which frame the orientation was always in - the ' ...
  'numbers do not change. To move it into that frame use ' ...
  '<a href="matlab:mtexShowDoc(''orientation.transformReferenceFrame'')">' ...
  'transformReferenceFrame</a>. This line will not say so again.'],what);

end
