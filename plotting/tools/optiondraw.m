function h = optiondraw(h,varargin)
% apply options to handle
%
if isempty(h) || isempty(varargin), return; end

% extract options
options = extract_argoption(varargin,fieldnames(handle(h)));

% set options
if ~isempty(options), set(h,options{:});end
