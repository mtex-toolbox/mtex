function value = out2(fun,varargin)
% return second output of a function, useful in anonymous functions

[~,value] = fun(varargin{:});

end