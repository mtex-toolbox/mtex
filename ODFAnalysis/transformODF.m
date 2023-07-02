function odfC = transformODF(odfP,p2c,varargin)
% transformatation texture
%
% Description
% ...
%
% Syntax
%   odfC = transformODF(odfP,p2c)
%
%   vSel = [0.1 0.2 0.]
%   odfC = transformODF(odfP,p2c,'variantSelection',vSel)
%
%   % only variant 3 is considered
%   odfC = transformODF(odfP,p2c,'variantSelection',3)
%
% Input
%  odfP - parent ODF @SO3Fun
%  p2c  - parent to child orientation relationship
%
% Options
%  variantSelection - 
%
% Output
%  odfC - child ODF @SO3Fun
%
% Example
% 
% 
% 

odfC = SO3FunHarmonic.quadrature( ...
  @(ori) localEval(ori,odfP,p2c,varargin{:}), p2c.SS,'bandwidth',odfP.bandwidth);

end

function val = localEval(cori,odf,p2c,vSel)

if nargin == 3
  pori =  p2c.variants(cori);
  val = mean(odf.eval(pori),2);
else
  pori = cori * (p2c.SS.rot * p2c);
  vVal = vSel.eval(pori);
  vVal = vVal ./ mean(vVal,2);
  val = mean(odf.eval(pori) .* vVal,2);
end

end


