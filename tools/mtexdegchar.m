function c = mtexdegchar
% returns the degree character defined by the global varaibel mtex_degree

c = get_mtex_option('degree_char',native2unicode([194 176],'UTF-8'),'char');
