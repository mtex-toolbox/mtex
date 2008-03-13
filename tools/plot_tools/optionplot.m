function optionplot(x,y,varargin)
% plot y against x using the options in varargin
%


if check_option(varargin,'logarithmic')
  h = semilogy(x,y);
else
  h = plot(x,y);
end

fn = fieldnames(get(h));
plotopt = extract_argoption(varargin,fn);
if ~isempty(plotopt), set(h,plotopt{:});end

