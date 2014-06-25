function [w3j,jmin, jmax] = Wigner3j_new(j2, j3, m1, m2, m3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	This subroutine will calculate the Wigner 3j symbols
%
%		j  j2 j3
%		m1 m2 m3
%
%	for all allowable values of j. The returned values in the array j are 
%	calculated only for the limits
%
%		jmin = max(|j2-j3|, |m1|)
%		jmax = j2 + j3
%
%	To be non-zero, m1 + m2 + m3 = 0. In addition, it is assumed that all j and m are 
%	integers. Returned values have a relative error less than ~1.d-8 when j2 and j3 
%	are less than 103 (see below). In practice, this routine is probably usable up to 165.
%
%	This routine is based upon the stable non-linear recurence relations of Luscombe and 
%	Luban (1998) for the "non classical" regions near jmin and jmax. For the classical 
%	region, the standard three term recursion relationship is used (Schulten and Gordon 1975). 
%	Note that this three term recursion can be unstable and can also lead to overflows. Thus 
%	the values are rescaled by a factor "scalef" whenever the absolute value of the 3j coefficient 
%	becomes greater than unity. Also, the direction of the iteration starts from low values of j
%	to high values, but when abs(w3j(j+2)/w3j(j)) is less than one, the iteration will restart 
%	from high to low values. More efficient algorithms might be found for specific cases 
%	(for instance, when all m's are zero).
%
%	Verification: 
%
%	The results have been verified against this routine run in quadruple precision.
%	For 1.e7 acceptable random values of j2, j3, m2, and m3 between -200 and 200, the relative error
%	was calculated only for those 3j coefficients that had an absolute value greater than 
%	1.d-17 (values smaller than this are for all practical purposed zero, and can be heavily 
%	affected by machine roundoff errors or underflow). 853 combinations of parameters were found
%	to have relative errors greater than 1.d-8. Here I list the minimum value of max(j2,j3) for
%	different ranges of error, as well as the number of times this occured
%	
%	1.d-7 < error  <=1.d-8 = 103	# = 483
%	1.d-6 < error <= 1.d-7 =  116	# = 240
%	1.d-5 < error <= 1.d-6 =  165	# = 93
%	1.d-4 < error <= 1.d-5 = 167	# = 36
%
%	Many times (maybe always), the large relative errors occur when the 3j coefficient 
%	changes sign and is close to zero. (I.e., adjacent values are about 10.e7 times greater 
%	in magnitude.) Thus, if one does not need to know highly accurate values of the 3j coefficients
%	when they are almost zero (i.e., ~1.d-10)  this routine is probably usable up to about 160.
%
%	These results have also been verified for parameter values less than 100 using a code
%	based on the algorith of de Blanc (1987), which was originally coded by Olav van Genabeek, 
%	and modified by M. Fang (note that this code was run in quadruple precision, and
%	only calculates one coefficient for each call. I also have no idea if this code
%	was verified.) Maximum relative errors in this case were less than 1.d-8 for a large number
%	of values (again, only 3j coefficients greater than 1.d-17 were considered here).
%	
%	The biggest improvement that could be made in this routine is to determine when one should
%	stop iterating in the forward direction, and start iterating from high to low values. 
%
%	Calling parameters
%		IN	
%			j2, j3, m1, m2, m3 	Integer values.
%		OUT	
%			w3j			Array of length jmax - jmin + 1.
%			jmin, jmax		Minimum and maximum values
%						out output array.
%	Dependencies: None
%	
%	Written by Mark Wieczorek August (2004)
%
%	August 2009: Based on the suggestions of Roelof Rietbroek, the calculation of RS has been slightly
%	modified so that division by zero will not cause a run time crash (this behavior depends on how the 
%	compiler treats IEEE floating point exceptions). These values were never used in the original code 
%	when this did occur.
%
%	Copyright (c) 2005-2009, Mark A. Wieczorek
%	All rights reserved.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	implicit none
%	integer, intent(in) ::	j2, j3, m1, m2, m3
%	integer, intent(out) ::	jmin, jmax
%	real*8, intent(out) ::	w3j(:)
%	real*8 ::		wnmid, wpmid, scalef, denom, rs(j2+j3+1), &
%				wl(j2+j3+1), wu(j2+j3+1), xjmin, yjmin, yjmax, zjmax, xj, zj
%	integer :: 		j, jnum, jp, jn, k, flag1, flag2, jmid
	

%% some basic constants

flag1 = 0;
flag2 = 0;
	
scalef = 1;
	
jmin = max(abs(j2-j3), abs(m1));
jmax = j2 + j3;
jnum = jmax - jmin + 1;

w3j = zeros(1,jnum);

%% some simple functions
jindex = @(j) j-jmin+1;

a = @(j) sqrt((j.^2 - (j2-j3).^2) .* ((j2+j3+1).^2 - j.^2) * (j.^2-m1^2));

y= @(j) -(2*j+1) .* ( m1 .* (j2.*(j2+1) - j3*(j3+1)) - (m3-m2).*j.*(j+1));
  
x = @(j) j .* a(j+1);
		
z = @(j) (j+1) .* a(j);

%% exclude some basic cases	which give zero
if abs(m2) > j2 || abs(m3) > j3
  return
elseif m1 + m2 + m3 ~= 0
  return
elseif jmax < jmin
  return
end
	
%% Only one term is present
	
if jnum == 1
  
  w3j = 1 / sqrt(2 * jmin + 1);
  
  if (w3j < 0 && (-1)^(j2-j3+m2+m3) > 0) || ...
      (w3j > 0 && (-1)^(j2-j3+m2+m3) < 0)
    w3j = -w3j;
  end
  return
  
end
		
%% more then one term
%
% Calculate lower non-classical values for [jmin, jn]. If the second term
%	can not be calculated because the recursion relationsips give rise to a
%	1/0,  set flag1 to 1.  If all m's are zero,  this is not a problem
%	as all odd terms must be zero.
%

	
rs = 0;
wl = 0;
	
xjmin = x(jmin);
yjmin = y(jmin);
	
if (m1 == 0 && m2 == 0 && m3 == 0) % All m's are zero
	
  wl(jindex(jmin)) = 1;
  wl(jindex(jmin+1)) = 0;
  jn = jmin+1;
  
elseif yjmin == 0 % The second terms is either zero
	
  if xjmin == 0   % or undefined
    flag1 = 1;
    jn = jmin;
  else
    wl(jindex(jmin)) = 1;
    wl(jindex(jmin+1)) = 0;
    jn = jmin+1;
  end
		
elseif xjmin * yjmin >= 0 % The second term is outside of the non-classical region
  
  wl(jindex(jmin)) = 1;
  wl(jindex(jmin+1)) = -yjmin / xjmin;
  jn = jmin+1;
		
else							% Calculate terms in the non-classical region
	
  rs(jindex(jmin)) = -xjmin / yjmin;
		
  jn = jmax;
  for j = jmin + 1:jmax-1
    
    denom =  y(j) + z(j)*rs(jindex(j-1));
    xj = x(j);
    if abs(xj) > abs(denom) || xj * denom >= 0 || denom == 0
      jn = j-1;
      break
    else
      rs(jindex(j)) = -xj / denom;
    end
				
  end
		
  wl(jindex(jn)) = 1;
		
  for k = 1:jn - jmin
      
    wl(jindex(jn-k)) = wl(jindex(jn-k+1)) * rs(jindex(jn-k));
      
  end
    
  if jn == jmin	% Calculate at least two terms so that
      
    wl(jindex(jmin+1)) = -yjmin / xjmin;		% these can be used in three term
    jn = jmin+1;					% recursion
            
  end

end
	
if jn == jmax					% All terms are calculated
	
  w3j = wl;
  
  % normalize
  norm = sum((2*(jmin:jmax)+1) .* w3j.^2);
  w3j = w3j ./ sqrt(norm);

  % fix sign
  if (w3j(end) < 0 && (-1)^(j2-j3+m2+m3) > 0) || ...
      (w3j(end) > 0 && (-1)^(j2-j3+m2+m3) < 0)
    w3j = -w3j;
  end
    
  return
end

%%
%
% 	Calculate upper non-classical values for [jp, jmax].
%	If the second last term can not be calculated because the
%	recursion relations give a 1/0,  set flag2 to 1.
%	(Note, I don't think that this ever happens).
%

wu = 0;
	
yjmax = y(jmax);
zjmax = z(jmax);
	
if (m1 == 0 && m2 == 0 && m3 == 0)
	
  wu(jindex(jmax)) = 1;
  wu(jindex(jmax-1)) = 0;
  jp = jmax-1;
		
elseif yjmax == 0
	
  if zjmax == 0
    flag2 = 1;
    jp = jmax;
  else
    wu(jindex(jmax)) = 1;
    wu(jindex(jmax-1)) = - yjmax / zjmax;
    jp = jmax-1;
  end
		
elseif yjmax * zjmax >= 0
	
  wu(jindex(jmax)) = 1;
  wu(jindex(jmax-1)) = - yjmax / zjmax;
  jp = jmax-1;

else
  rs(jindex(jmax)) = -zjmax / yjmax;

  jp = jmin;
  for j = jmax-1:-1:jn
      
    denom = y(j) + x(j)*rs(jindex(j+1));
    zj = z(j);
    if abs(zj) > abs(denom) || zj * denom >= 0 || denom == 0
      jp = j+1;
      break
    else
      rs(jindex(j)) = -zj / denom;
    end
      
  end
		
  wu(jindex(jp)) = 1;
  
  for k=1:jmax - jp
    wu(jindex(jp+k)) = wu(jindex(jp+k-1))*rs(jindex(jp+k));
  end
    
		
  if jp == jmax
    wu(jindex(jmax-1)) = - yjmax / zjmax;
    jp = jmax-1;
  end
		
end
	
%% 
%
% 	Calculate classical terms for [jn+1, jp-1] using standard three
% 	term rercusion relationship. Start from both jn and jp and stop at the
% 	midpoint. If flag1 is set,  perform the recursion solely from high to
% 	low values. If flag2 is set,  perform the recursion solely from low to high.
	
if flag1 == 0
	
  jmid = ceil((jn + jp)/2);
		
  for j = jn : jmid - 1
      
    wl(jindex(j+1)) = - (z(j)*wl(jindex(j-1)) +y(j)*wl(jindex(j))) / x(j);
			
    if abs(wl(jindex(j+1))) > 1 				% watch out for overflows.
      wl(jindex(jmin):jindex(j+1)) = wl(jindex(jmin):jindex(j+1)) / scalef;
    end
			
    % if values are decreasing
    if (abs(wl(jindex(j+1)) / wl(jindex(j-1))) < 1 && wl(jindex(j+1)) ~= 0)
      
      %  stop upward iteration
      jmid = j+1;	% and start with the downward
      break	% iteration.
    end
  end
		
  wnmid = wl(jindex(jmid));
		
  if (abs(wnmid/wl(jindex(jmid-1))) < 1e-6 && ...
      wl(jindex(jmid-1)) ~= 0) 				% Make sure that the stopping
    
    wnmid = wl(jindex(jmid-1));					% midpoint value is not a zero,
    jmid = jmid - 1;							% or close to it%
  end
		
		
  for j=jp:-1:jmid+1
    wu(jindex(j-1)) = - (x(j)*wu(jindex(j+1)) + y(j)*wu(jindex(j)) ) / z(j);
    if (abs(wu(jindex(j-1))) > 1)
      wu(jindex(j-1):jindex(jmax)) = wu(jindex(j-1):jindex(jmax)) / scalef;
    end
    
  end
		
  wpmid = wu(jindex(jmid));
		
  % rescale two sequences to common midpoint
		
  if jmid == jmax
    w3j(1:jnum) = wl(1:jnum);
  elseif jmid == jmin
    w3j(1:jnum) = wu(1:jnum);
  else
    w3j(1:jindex(jmid)) = wl(1:jindex(jmid)) * wpmid / wnmid;
    w3j(jindex(jmid+1):jindex(jmax)) = wu(jindex(jmid+1):jindex(jmax));
  end
		
elseif (flag1 == 1 && flag2 == 0) 	% iterature in downward direction only
		
  for j=jp:-1:jmin+1
    wu(jindex(j-1)) = - (x(j)*wu(jindex(j+1)) + y(j)*wu(jindex(j)) ) / z(j);
    if (abs(wu(jindex(j-1))) > 1)
      wu(jindex(j-1):jindex(jmax)) = wu(jindex(j-1):jindex(jmax)) / scalef;
    end
  end
		
  w3j(1:jnum) = wu(1:jnum);
		
elseif flag2 == 1 && flag1 == 0 % iterature in upward direction only
		
  for j = jn:jp-1
    wl(jindex(j+1)) = - (z(j)*wl(jindex(j-1)) +y(j)*wl(jindex(j))) / x(j);
    if abs(wl(jindex(j+1))) > 1
      wl(jindex(jmin):jindex(j+1)) = wl(jindex(jmin):jindex(j+1))/ scalef;
    end
  end
		
  w3j = wl;
		
elseif flag1 == 1 && flag2 == 1

  error('Can not calculate function for input values');

end

% normalize
norm = sum((2*(jmin:jmax)+1) .* w3j.^2); 
w3j = w3j ./ sqrt(norm);

% fix sign
if (w3j(end) < 0 && (-1)^(j2-j3+m2+m3) > 0) || ...
    (w3j(end) > 0 && (-1)^(j2-j3+m2+m3) < 0)
  w3j = -w3j;
end

		
end

