function assert(cond,varargin)

if isempty(varargin)
  msg = 'Assertion failed.';
else
  msg = varargin{1};
end
if ~cond, error(msg);end

