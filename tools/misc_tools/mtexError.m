function mtexError(varargin)
% raises an error without specifying backtrace

title = 'MTEX';

err.message = sprintf(varargin{:});
err.identifier = "MTEX:" + stripws(title);
err.stack.file = '';
err.stack.name = char(title);
err.stack.line = 1;

error(err)

end