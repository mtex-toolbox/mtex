function mtexWarnOnce(id,varargin)
% warn about the line the user wrote, and only the first time it runs
%
% A note that a line could be written better has to reach that line - not
% the MTEX file that happens to execute it, and not once per element of a
% loop that runs it a million times. So this fires for the first caller
% outside the MTEX install and remembers the file and line it fired for.
%
% A call typed at the command window has no file to name and is not warned
% about: it is one line, its result is on the screen, and there is nothing
% to find later.
%
% Syntax
%
%   mtexWarnOnce('MTEX:frameAssigned','use %s instead','transformReferenceFrame')
%   mtexWarnOnce('-reset-')   % forget every site, for tests
%
% Input
%  id     - warning identifier, so a user can switch it off with warning('off',id)
%  format - format string as accepted by sprintf
%
% See also
% mtexWarning mtexError

persistent seen

if isempty(seen), seen = containers.Map; end
if nargin == 1 && strcmp(id,'-reset-'), seen = containers.Map; return; end

% a user who switched this note off pays nothing for it - reading the stack
% is what costs here
w = warning('query',id);
if strcmp(w.state,'off'), return; end

st = dbstack('-completenames');
st(1) = [];   % this function

k = find(~startsWith({st.file},mtex_path),1);
if isempty(k), return; end

site = sprintf('%s|%d|%s',st(k).file,st(k).line,id);
if seen.isKey(site), return; end
seen(site) = true;

mtexWarning(id,varargin{:});

end
