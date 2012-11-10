function h = optiondraw(h,varargin)
% plot y against x using the options in varargin
%
if isempty(h) || isempty(varargin), return; end

% % extract prefix masked options
% if check_option(varargin,'prefix')
% 
%   prefix = get_option(varargin,'prefix');
%   options = delete_option(options,'prefix',1);
% 
%   i = 1;
%   while i<= length(options)
%     if isa(options{i},'char') && ~isempty(strmatch(prefix,options{i}))
%       options{i} = strrep(options{i},prefix,'');
%       i = i + 2;
%     else
%       options(i) = [];
%     end
%   end
% 
% end

% extract options
options = extract_argoption(varargin,fieldnames(handle(h)));

% set options
if ~isempty(options), set(h,options{:});end
