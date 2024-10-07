function varargout = plot(q,varargin)
% plot
%
% see also
% rotation/plot

[varargout{1:nargout}] = scatter(q,varargin{:});