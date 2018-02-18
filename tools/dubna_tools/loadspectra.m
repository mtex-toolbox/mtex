function sp = loadspectra(filename)
% load a single spectrum o a Dubna meassurement

fid=fopen(filename,'r');
if fid>0
    A = fread(fid,'uint8');
    sp = A(1:2:end)*256 + A(2:2:end);
    fclose(fid);
else
    sp = [];
end
