/*
 * Transform the integer which includes the flags to boolean vector.
 *
 * The bit assignment below is the one all callers implement. Note that an
 * earlier version of this comment listed a different one (2^0 real valued,
 * 2^2 L2-normalized, 2^3 precompute), which never matched the code.
 *
 * flags:  2^0 -> use L_2-normalized Wigner-D functions / spherical harmonics
 *         2^1 -> make size of the result even
 *         2^2 -> fhat are the coefficients of a real valued function
 *         2^3 -> fhat are the coefficients of an antipodal function
 *         2^4 -> use right and left symmetry
 *
 * The previous implementation subtracted 2^6 ... 2^0 greedily, which decodes
 * anything at or above 2^7 as *every* flag set at once: get_flags(128,...)
 * returned real + even + antipodal + symmetric + L2 with no complaint. Out of
 * range flag words are now rejected instead of silently turning on features.
 */

static void get_flags(mxDouble number, bool flags[7])
{
  if( number != floor(number) || number < 0 || number >= 32 )
    mexErrMsgIdAndTxt("MTEX:get_flags:invalidFlags",
      "flags must be a non-negative integer below 32 (2^0 + ... + 2^4), got %g.",number);

  const int f = (int) number;
  for (int i = 0; i < 7; i++)
    flags[i] = (f >> i) & 1;
}
