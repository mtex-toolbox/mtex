function strw = wraptext(str,width)
% wraptext formats long strings into wrapped text of specified width. 
% 
%% Syntax
% 
%  wraptext(str) 
%  wraptext(str,width) 
%  strw = wraptext(...)
% 
%% Description 
% 
% wraptext(str) wraps the text in str and prints it in the command window. 
%
% wraptext(str,width) wraps text to a specified width in characters. If width
% is not specified, the current width of your command window is used.
% 
% strw = wraptext(...) writes output to a variable in your workspace. 
% 
%% Example 1: 
% Print text to your command window: 
% 
% str = 'Lorem interdum nescio ubi sordida iter ducis, interdum nec video cur.  Ego coniecto ego servo in ludum properamus, multa cervisia et multa vagabundos inruisse.  Facilius quam mori dum circum. Unum tempus habui amicos ma, etiam pa habebat, Et lumbare caedebat ostendam exclamavit, Nympha iubet operam me descendit vetusto Tennessium, Facilius quam mori dum circum.  In aetatem veni inuenit puellam Tuscaloosa bar, Ipsa purgata a me foras, et ledo eam clanculum, Et volebat occidere dolore emi vino tripudio agmine, Facilior visa est quam iustus expectans circa mori.  Amicus quidam dixit se scire facile pecuniae, Et vir fratrem suum fecerunt depraedantes avolavimus, Posse me adsecutus est veneno ad me Muskogee, Suus duobus annis circiter mori iustus expectans. Quod de carcere catenisque interdum Im Possedi amicum tandem, Ille ne occidas ne fureris aut fallere aut in potu aut in mendacio, Codeine nomen suum, quod ipse vidi Qui viatoribus, Simul sumus agnus dei haerere et morietur.';
% wraptext(str) 
% 
%% Example 2: 
% Write a string to your workspace and make it does not exceed 33
% characters width: 
% 
% str = 'Lorem interdum nescio ubi sordida iter ducis, interdum nec video cur.  Ego coniecto ego servo in ludum properamus, multa cervisia et multa vagabundos inruisse.  Facilius quam mori dum circum. Unum tempus habui amicos ma, etiam pa habebat, Et lumbare caedebat ostendam exclamavit, Nympha iubet operam me descendit vetusto Tennessium, Facilius quam mori dum circum.  In aetatem veni inuenit puellam Tuscaloosa bar, Ipsa purgata a me foras, et ledo eam clanculum, Et volebat occidere dolore emi vino tripudio agmine, Facilior visa est quam iustus expectans circa mori.  Amicus quidam dixit se scire facile pecuniae, Et vir fratrem suum fecerunt depraedantes avolavimus, Posse me adsecutus est veneno ad me Muskogee, Suus duobus annis circiter mori iustus expectans. Quod de carcere catenisque interdum Im Possedi amicum tandem, Ille ne occidas ne fureris aut fallere aut in potu aut in mendacio, Codeine nomen suum, quod ipse vidi Qui viatoribus, Simul sumus agnus dei haerere et morietur.';
% wrapped_string = wraptext(str,33); 
% 
%% Author Info: 
% This function was written by Chad A. Greene of the University of Texas
% at Austin's Institute for Geophysics (UTIG), September 2015. 
% http://www.chadagreene.com
% 
% See also: sprintf, fprintf, regexp, and disp. 
%% Error checks: 
assert(nargin>0,'The wrapdisp function requires at least one input.') 
assert(ischar(str)==1,'Input str must be a string.') 
%% Input parsing: 
% If no width is specified, use width of command window: 
if nargin==1
    cms = get(0,'CommandWindowSize'); 
    width = cms(1); 
else
    assert(isscalar(width)==1,'Width must be a scalar.') 
end
% Find spaces: 
r = regexp(str,' '); 
% Throw error if any words are longer than specified width: 
if any(diff(r)>width)
    error('Sorry, it looks like some words in the input string are longer than the specified width. Either increase the width allowance or break up long words with a hyphen followd by a space.') 
end
k = 0; % counter 
n = 1; 
% find longest possible lines: 
while k <r(end) 
    f(n) = r(find(r<=k+width,1,'last')); 
    k = f(n); 
    n = n+1; 
end
% concatenate the string accordingly: 
newstr = [str(1:f(1)),'\n'];
for k = 1:length(f)-1
    newbit = str(f(k)+1:f(k+1)); 
    if k==length(f)-1 
        newstr(length(newstr)+1:length(newstr)+length(newbit)) = newbit; 
    else   
        newstr(length(newstr)+1:length(newstr)+length(newbit)+2) = [newbit,'\n']; 
    end
end
lastbit = str(f(end)+1:end); 
newstr(length(newstr)+1:length(newstr)+length(lastbit)) = lastbit; 
% Output: 
if nargout==1
    strw = sprintf(newstr); 
else
    fprintf([newstr,'\n'])
end