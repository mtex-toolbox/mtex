function c = classifyParts(T,varargin)
% candidate class of every part from its features, all lengths in pixels
%
%  noise  - a thin part, which the closing with the opening radius fills
%  crack  - a thick part whose maximum Feret diameter is at least lam times its width
%  void   - a thick part touching the edge of the scan
%  pore   - a thick part with one orientation on at least share of its rim
%  pocket - all other thick parts

lam   = get_option(varargin,'lam',4);
share = get_option(varargin,'share',0.85);

w = 2*T.rMax - 1;
c = repmat("pocket",height(T),1);
c(T.oriShare1 >= share) = "pore";
c(T.border) = "void";
c(T.feret >= lam*w) = "crack";
c(~T.isThick) = "noise";
c = categorical(c,["noise" "crack" "void" "pore" "pocket"]);
end
