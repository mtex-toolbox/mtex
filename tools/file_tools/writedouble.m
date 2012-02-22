function writedouble(filename,x)
% write to file

fid=fopen(filename,'w');
fwrite(fid,x,'double');
fclose(fid);
