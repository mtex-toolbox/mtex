function [ output_args ] = contourf( v, varargin )


cl = get_option(varargin,'contours',10);

smooth(v,varargin{:},'contours',cl,'LineStyle','none','fill','on')
smooth(v,varargin{:},'contours',cl,'LineStyle','-','LineColor','k','fill','off')
