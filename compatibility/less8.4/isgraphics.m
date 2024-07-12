function out = isgraphics(h,type)

out = ishandle(h) && strcmpi(get(h,'type'),type);

end

