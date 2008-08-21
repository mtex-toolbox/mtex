function pf = correct( pf, varargin )
% corrects a (list of) polfigure(s)
%
%% Syntax
% pf = correct(pf,<options>)
%
%% Input
%  pf - list of @PoleFigure
%
%% Options
%  BACKGROUND | BG                - Background PoleFigure
%  DEFOCUSING | DEF               - Defocusing PoleFigure
%  BACKGROUND DEFOCUSING | DEF_BG - Background of defocusing PoleFigure
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% xrdml_interface loadPoleFigure_xrdml

p{1} = get_option(varargin,{'background','bg'});
p{2} = get_option(varargin,{'defocusing','def'});
p{3} = get_option(varargin,{'defocusing background','def_bg'});

epsilon = 1e-9;

for i=1:length(pf)
  for k=1:3 
    if ~isempty(p{k})
      if geth(p{k}(i)) == geth(pf(i)) 
        theta = getTheta(getr(p{k}(i)));     
        for g=1:GridLength(getr(p{k}(i)))
          id = find(getTheta(getr(pf(i))) >= theta(g)-epsilon &...
            getTheta(getr(pf(i))) <= theta(g)+epsilon);
          d(id) = getdata(p{k}(i),g);
        end  
        p{k}(i) = PoleFigure(getMiller(pf(i)),...
          getr(pf(i)),d,...
          getCS(pf(i)),getSS(pf(i)));
      else
         error('crystal direction missmatch');
      end     
    end   
  end
end

if ~isempty(p{1}), pf = pf-p{1}; end

if ~isempty(p{2}) && ~isempty(p{3})
  p{2} = p{2} - p{3}; end

if ~isempty(p{2}), pf = pf/p{2}; end




