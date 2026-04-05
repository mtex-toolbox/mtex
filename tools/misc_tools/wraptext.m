function out = wraptext(txt,width)
% WRAPTEXT Wrap text to a maximum line length (Unicode-aware).
%   out = wraptext(txt,width) returns text where each original line is
%   wrapped so that no wrapped line exceeds 'width' visible characters.
%   Words are not split.
%
%   Extra rules:
%   1) Existing newline characters in TXT are respected. I.e. each
%      paragraph (line) is wrapped independently and separated by '\n'
%      exactly as in the input.
%   2) HTML fragments of the form <a ...>...</a> are treated as a single
%      unbreakable word, even if they contain spaces in attributes.
%
%   txt   ... string or char
%   width ... positive integer
%
%   Returns a char vector with '\n' as newline separators.

if nargin==1
  cms = get(0,'CommandWindowSize');
  width = cms(1);
else
  assert(isscalar(width),'Width must be a scalar.')
end

% normalize to string scalar
if ~isstring(txt), txt = string(txt); end

if numel(txt) ~= 1
  txt = join(txt,newline); % just in case user passed string array
end

% split on existing newlines, keep empties
lines_in = split(txt, newline);

wrapped_lines_all = strings(0,1);

for L = 1:numel(lines_in)
  paragraph = lines_in(L);

  % If the paragraph is empty, preserve an empty line
  if strlength(paragraph)==0
    wrapped_lines_all(end+1,1) = ""; %#ok<AGROW>
    continue
  end

  % --- 1) protect <a ...>...</a> blocks so we don't split them ---
  % We will replace spaces INSIDE each <a ...>...</a> block by
  % a non-breaking placeholder, wrap, then restore.
  protected_paragraph = paragraph;
  placeholder = char(160); % non-breaking space (&nbsp;)

  % Find all <a ...>...</a> segments (non-greedy match)
  anchor_pat = "<a\b.*?>.*?</a>";
  [startIdx,endIdx] = regexp(protected_paragraph, anchor_pat, 'start','end','once');

  % We may have multiple <a>...</a>, so loop carefully
  while ~isempty(startIdx)
    before  = extractBetween(protected_paragraph, 1, startIdx-1);
    anchor  = extractBetween(protected_paragraph, startIdx, endIdx);
    after   = extractBetween(protected_paragraph, endIdx+1, strlength(protected_paragraph));

    % Replace normal spaces in the anchor block by placeholder
    anchor = replace(anchor," ",placeholder);
    
    % Reassemble
    protected_paragraph = before + anchor + after;
    
    % search again (continue after this anchor)
    offset = endIdx; % position in ORIGINAL string
    % But since string lengths changed only by 1:1 replacement,
    % indices are still consistent. We can just search again fresh:
    [startIdx,endIdx] = regexp(protected_paragraph, anchor_pat, 'start','end','once');
    % Note: this finds from beginning again, but since we've already
    % replaced spaces in this anchor, running again will skip it
    % because pattern still matches <a ...>...</a>. That's fine,
    % because replacing spaces with placeholder didn't change '<' or '>'.
    % So multiple anchors still get processed eventually.
  end

  % --- 2) split into "words" by real spaces ---
  words = split(protected_paragraph," ");
  
  % --- 3) actual wrapping ---
  current = "";
  wrapped_lines = strings(0,1);
  
  for k = 1:numel(words)
    w = words(k);
    
    % restore placeholders only for measuring length
    w_len = strlength(replace(w,placeholder," "));
    
    if current == ""
      % starting a new output line
      if w_len > width
        % word alone longer than width -> force on its own line
        wrapped_lines(end+1,1) = replace(w,placeholder," "); %#ok<AGROW>
        current = "";
      else
        current = w;
      end
    else
      curr_len = strlength(replace(current,placeholder," "));
      if curr_len + 1 + w_len <= width
        current = current + " " + w;
      else
        % push current
        wrapped_lines(end+1,1) = replace(current,placeholder," "); %#ok<AGROW>
        
        if w_len > width
          wrapped_lines(end+1,1) = replace(w,placeholder," "); %#ok<AGROW>
          current = "";
        else
          current = w;
        end
      end
    end
  end
  
  if current ~= ""
    wrapped_lines(end+1,1) = replace(current,placeholder," "); %#ok<AGROW>
  end
  
  % append all wrapped lines for this paragraph
  wrapped_lines_all = [wrapped_lines_all; wrapped_lines]; %#ok<AGROW>

end

% Join everything with '\n'
out = strjoin(wrapped_lines_all, newline);
out = char(out); % char is handy for fprintf, etc.

if nargout==0
  disp(out); 
  clear out
end


end
