function str = file2cell(filename,maxline)
% reads a file rowise into a cellstr
%
% Lines are separated by the line feed character only and a trailing
% carriage return is removed. This is exactly how txt2mat counts lines.
% Note that fgetl in contrast breaks at a stray carriage return as well -
% a file with CRLF line breaks that contains an additional CR (as written
% by some EDAX .ang exports) would then appear to have more lines here than
% when the very same file is read by txt2mat, and the header line count
% handed over to it would be too large.

if nargin == 1, maxline = inf; end

fid = efopen(filename,'r');

str = {};
buffer = '';
blockSize = 2^16;

while true

  block = fread(fid,blockSize,'*char').';
  atEOF = isempty(block);
  buffer = [buffer, block]; %#ok<AGROW>

  % positions of all completed lines
  stop = find(buffer == newline);

  % a last line without a trailing line break
  if atEOF && ~isempty(buffer) && (isempty(stop) || stop(end) < numel(buffer))
    stop = [stop, numel(buffer)+1]; %#ok<AGROW>
  end

  if ~isempty(stop)
    start = [1, stop(1:end-1)+1];
    str = [str, arrayfun(@(a,b) buffer(a:b-1),start,stop,'UniformOutput',false)]; %#ok<AGROW>
    buffer(1:min(stop(end),numel(buffer))) = [];
  end

  if atEOF || numel(str) >= maxline, break; end

end

fclose(fid);

% remove the carriage return of CRLF line breaks
str = regexprep(str,'\r+$','');

% stop at the first suspiciously long line - most likely not a text file
tooLong = find(cellfun('length',str) > 1000,1);
if ~isempty(tooLong), str = str(1:tooLong-1); end

if numel(str) > maxline, str = str(1:maxline); end
