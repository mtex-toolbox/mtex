function mtex_assert(cond,varargin)

if isempty(which('assert'))
  if isempty(varargin)
    msg = 'Assertion failed.';
  else
    msg = varargin{1};
  end
  if ~cond, error(msg);end
else
  assert(cond,varargin{:});
end
