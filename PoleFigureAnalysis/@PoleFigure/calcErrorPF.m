function pfcalc = calcErrorPF(pfmeas,pfcalc,varargin)
% error pole figure between measured and recalculated pole figures
%
% returns a @PoleFigure with values given as the difference between the
% measured intensities and the recalculated @SO3Fun or between two measured
% @PoleFigure.
%
% Syntax
%   pf = calcErrorPF(pfmeas,pfcalc) %
%   pf = calcErrorPF(pfmeas,odf)    %
%
% Input
%  pfmeas - meassured @PoleFigure 
%  pfcalc - recalculated @PoleFigure
%  odf    - recalculated @SO3Fun
%
% Options
%  RP    - RP value (default) |pfmeas - pfcalc|./ pfcalc
%  l1    - l1 error           |pfmeas - pfcalc|
%  l2    - l2 error           |pfmeas - pfcalc|.^2
%
% Output
%  pf - @PoleFigure 
%
% See also
%  PoleFigure/calcError SO3Fun/calcPoleFigure

% evaluate ODF if necessary
if isa(pfcalc,'SO3Fun')
  pfcalc = calcPoleFigure(pfcalc,pfmeas.allH,pfmeas.allR,'superposition',pfmeas.c);
end

progress(0,pfmeas.numPF);
for i = 1:pfmeas.numPF
  
  % normalization
  alpha = calcNormalization(pfmeas.select(i),pfcalc.select(i));
  
  d1 = pfmeas.allI{i};
  d2 = pfcalc.allI{i} * alpha;
  
  if check_option(varargin,'l1')    
    d = abs(d1-d2);    
  elseif check_option(varargin,'l2')
    d = (d1-d2).^2;
  elseif check_option(varargin,'RP')
    epsilon = get_option(varargin,'RP',1,'double');
    ind = d2 > epsilon*alpha;
    d = abs(d1(ind)-d2(ind))./d2(ind);
    pfcalc.allR{i} = pfcalc.allR{i}(ind);
  else
    epsilon = get_option(varargin,'epsilon',0.5,'double');
    d = abs(d1-d2)./max(d1+epsilon*alpha,d2+epsilon*alpha);
    %d = abs(d1-d2)./(d1+epsilon*alpha);
  end
  pfcalc.allI{i} = d;
  progress(i,pfmeas.numPF);
end
