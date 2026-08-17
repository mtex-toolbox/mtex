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
%      unbreakable word, even if they contain spaces in attributes. They
%      count towards the line length by the text they show, not by the
%      length of their markup - a hyperlink that is only a few characters
%      wide on screen must not push the words around it onto the next line,
%      and a line must never be broken inside the tag, which would leave
%      the command window with markup it can no longer turn into a link.
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

  % Find all <a ...>...</a> segments (non-greedy match). Note that MATLAB
  % regexp has no \b for a word boundary - \b is a backspace character, so
  % the '<a\b' this used to look for never matched anything at all.
  anchor_pat = '<a[^>]*>.*?</a>';
  [startIdx,endIdx] = regexp(protected_paragraph, anchor_pat, 'start','end');

  % Replace normal spaces in every anchor block by the placeholder. Doing it
  % in place keeps the match positions valid - the replacement is one
  % character for one character - and needs no repeated search, which would
  % not terminate: the pattern still matches an anchor once its spaces are
  % gone.
  if ~isempty(startIdx)
    chars = char(protected_paragraph);
    for a = 1:numel(startIdx)
      seg = chars(startIdx(a):endIdx(a));
      seg(seg == ' ') = placeholder;
      chars(startIdx(a):endIdx(a)) = seg;
    end
    protected_paragraph = string(chars);
  end

  % --- 2) split into "words" by real spaces ---
  words = split(protected_paragraph," ");
  
  % --- 3) actual wrapping ---
  current = "";
  wrapped_lines = strings(0,1);
  
  for k = 1:numel(words)
    w = words(k);
    
    % restore placeholders only for measuring length
    w_len = visibleLength(w,placeholder);
    
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
      curr_len = visibleLength(current,placeholder);
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

% -----------------------------------------------------------------------

function len = visibleLength(w,placeholder)
% how wide does this word appear on screen
%
% The markup of a hyperlink is not on screen, only its link text is, so a
% one word link the command window shows as four characters must be counted
% as four - counting its 80 characters of markup pushes everything around it
% onto lines of its own for no reason.

len = strlength(regexprep(replace(w,placeholder," "),'<[^>]*>',''));

end
