function h = optionplot(x,y,varargin)
% plot y against x using the options in varargin
%

% new window?
if ~ishold && isappdata(gcf,'axes')
  clf;
end

% logarithmic plot?
if check_option(varargin,{'logarithmic','log'})
  h = semilogy(x,y);
else
  h = plot(x,y);
end

% extract options
fn = fieldnames(get(h));
plotopt = extract_argoption(varargin,fn);

% set options
if ~isempty(plotopt), set(h,plotopt{:});end

