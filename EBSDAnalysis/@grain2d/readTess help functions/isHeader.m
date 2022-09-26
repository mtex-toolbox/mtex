function returnvalue = isHeader(buffer)
returnvalue=strncmp(strtrim(buffer), "*", 1);