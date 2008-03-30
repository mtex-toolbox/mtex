function str = generateCodeString(strCells)
str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')];
end