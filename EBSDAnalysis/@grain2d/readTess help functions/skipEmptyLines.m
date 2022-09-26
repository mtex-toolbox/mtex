%to ignore possible emty lines
i=ftell(fid);
skipEmptyLinesBuffer=fgetl(fid);
while (skipEmptyLinesBuffer=="")
    i=ftell(fid);
    skipEmptyLinesBuffer=fgetl(fid);
end
fseek(fid, i, "bof");

clearvars i skipEmptyLinesBuffer