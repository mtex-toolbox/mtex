function mtexWarning(varargin)
% print a warning without a backtrace, wrapped to the command window
%
% Description
%
% The command window paints everything written to the error stream - which
% is what fprintf(2,...) does - in the colour set under Preferences ->
% Colors as "Error text", red by default. A note about an assumption MTEX
% made then looks exactly like a failed import, and users reasonably read it
% as one. Only text the warning function emits gets the "Warning text"
% colour, orange by default, so anything meant to be read as a warning has
% to go through warning.
%
% Two things about warning are in the way and are dealt with here: it
% appends the call stack, which for a note like this only names MTEX
% internals, and it does not wrap, so a paragraph runs off the window or
% breaks mid-word. The text is wrapped to leave room for the "Warning: "
% prefix, and hyperlinks survive it.
%
% Passing an identifier lets a user switch a recurring note off with
% warning('off',id).
%
% Syntax
%
%   mtexWarning(format,...)
%   mtexWarning(id,format,...)
%
% Input
%  id     - warning identifier, e.g. 'MTEX:eulerCorrectionAssumed'
%  format - format string as accepted by sprintf
%
% See also
% mtexError
%

% an identifier is a colon separated word, never a format string
if numel(varargin) > 1 && (ischar(varargin{1}) || isStringScalar(varargin{1})) && ...
    ~isempty(regexp(char(varargin{1}),'^\w+(:\w+)+$','once'))
  id = char(varargin{1});
  varargin(1) = [];
else
  id = 'MTEX:note';
end

% warning writes "Warning: " in front of the first line - wrap short enough
% that this does not push it past the window edge, and indent the rest to
% line up underneath it instead of leaving one long line above a narrow block
prefix = 'Warning: ';
cms = get(0,'CommandWindowSize');
msg = wraptext(sprintf(varargin{:}),max(40,cms(1)-numel(prefix)));

lines = split(string(msg),newline);
indent = [false; strlength(lines(2:end)) > 0];  % never pad a blank line
lines(indent) = blanks(numel(prefix)) + lines(indent);
msg = char(join(lines,newline));

% the call stack of a note about an assumption names nothing the user did
bt = warning('query','backtrace');
warning('off','backtrace');
resetBacktrace = onCleanup(@() warning(bt));

warning(id,'%s',msg);

end
