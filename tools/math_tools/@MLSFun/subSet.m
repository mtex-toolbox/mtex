function F = subSet(F,varargin)
% the components varargin of a vector valued MLS function

F.values = F.values(:,varargin{:});

end
