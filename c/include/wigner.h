/** 
 * \file wigner.h
 * 
 * \brief Header file for functions related to Wigner-d/D functions
 * 
 * \author Antje Vollrath
 */
#ifndef WIGNER_H
#define WIGNER_H
#include "api.h"

/**defines the absolute value */
#define ABS(A) ((A) > 0 ? (A) : (-A))

/**
 * Computes three-term recurrence coefficients \f$\alpha_l^{km}\f$ of  
 * Wigner-d functions
 *
 * \arg k The order \f$k\f$
 * \arg m The order  \f$m\f$
 * \arg l The degree \f$l\f$
 */ 
double SO3_alpha_al (int k, int m, int l);
/**
 * Computes three-term recurrence coefficients \f$\beta_l^{km}\f$ of  
 * Wigner-d functions
 *
 * \arg k The order \f$k\f$
 * \arg m The order  \f$m\f$
 * \arg l The degree \f$l\f$
 */ 
double SO3_beta_al (int k, int m, int l);
/**
 * Computes three-term recurrence coefficients \f$\gamma_l^{km}\f$ of  
 * Wigner-d functions
 *
 * \arg k The order \f$k\f$
 * \arg m The order  \f$m\f$
 * \arg l The degree \f$l\f$
 */ 
double SO3_gamma_al (int k, int m, int l);
/**
 * Compute three-term-recurrence coefficients \f$ \alpha_{l}^{km}\f$ of 
 * Wigner-d functions for all degrees \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg m the first order
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_alpha_al_row(double *alpha, int N,int m, int n);
/**
 * Compute three-term-recurrence coefficients \f$ \beta_{l}^{km}\f$ of 
 * Wigner-d functions for all degrees \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg m the first order
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_beta_al_row(double *beta, int N, int m,  int n);
/**
 * Compute three-term-recurrence coefficients \f$ \gamma_{l}^{km}\f$ of 
 * Wigner-d functions for all degrees \f$ l= 0,\ldots,N \f$
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg m the first order
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_gamma_al_row(double *gamma, int N,int m, int n);
/**
 * Compute three-term-recurrence coefficients \f$ \alpha_{l}^{km}\f$ of 
 * Wigner-d functions for all order \f$ m = -N,\ldots,N \f$ and 
 * degrees \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_alpha_al_matrix(double *alpha, int N, int n);
/**
 * Compute three-term-recurrence coefficients \f$ \beta_{l}^{km}\f$ of 
 * Wigner-d functions for all order \f$ m = -N,\ldots,N \f$ and 
 * degrees \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_beta_al_matrix(double *beta, int N, int n);
/**
 * Compute three-term-recurrence coefficients \f$ \gamma_{l}^{km}\f$ of 
 * Wigner-d functions for all order \f$ m = -N,\ldots,N \f$ and 
 * degrees \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 * \arg n the second order
 * \arg N The upper bound \f$N\f$.
 */
void SO3_gamma_al_matrix(double *gamma, int N, int n);

/**
 * Compute three-term-recurrence coefficients \f$\alpha_{l}^{km}\f$ of 
 * Wigner-d functions for all \f$ k,m = -N,\ldots,N \f$ and \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 *
 * \arg N The upper bound \f$N\f$.
 */
void SO3_alpha_al_all(double *alpha, int N);
/**
 * Compute three-term-recurrence coefficients \f$\beta_{l}^{km}\f$ of 
 * Wigner-d functions for all \f$ k,m = -N,\ldots,N \f$ and \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 *
 * \arg N The upper bound \f$N\f$.
 */
void SO3_beta_al_all(double *beta, int N);
/**
 * Compute three-term-recurrence coefficients \f$\gamma_{l}^{km}\f$ of 
 * Wigner-d functions for all \f$ k,m = -N,\ldots,N \f$ and \f$ l= 0,\ldots,N \f$.
 * 
 * \arg alpha A pointer to an array of doubles of size \f$(2N+1)^2(N+1)\f$
 *
 * \arg N The upper bound \f$N\f$.
 */
void SO3_gamma_al_all(double *gamma, int N);


/**
 * Evaluates Wigner-d functions \f$d_l^{km}(x,c)\f$ using the 
 * Clenshaw-algorithm. 
 * 
 * \arg x A pointer to an array of nodes where the function is to be evaluated
 * \arg y A pointer to an array where the function values are returned
 * \arg size The length of x and y
 * \arg l The degree \f$l\f$
 * \arg alpha A pointer to an array containing the recurrence coefficients 
 *   \f$\alpha_c^{km},\ldots,\alpha_{c+l}^{km}\f$
 * \arg beta A pointer to an array containing the recurrence coefficients 
 *   \f$\beta_c^{km},\ldots,\beta_{c+l}^{km}\f$
 * \arg gamma A pointer to an array containing the recurrence coefficients 
 *   \f$\gamma_c^{km},\ldots,\gamma_{c+l}^{km}\f$
 */
void eval_wigner(double *x, double *y, int size, int l, double *alpha, 
  double *beta, double *gamma);
/**
 * Evaluates Wigner-d functions \f$d_l^{km}(x,c)\f$ using the 
 * Clenshaw-algorithm if it not exceeds a given threshold.
 * 
 * \arg x A pointer to an array of nodes where the function is to be evaluated
 * \arg y A pointer to an array where the function values are returned
 * \arg size The length of x and y
 * \arg l The degree \f$l\f$
 * \arg alpha A pointer to an array containing the recurrence coefficients 
 *   \f$\alpha_c^{km},\ldots,\alpha_{c+l}^{km}\f$
 * \arg beta A pointer to an array containing the recurrence coefficients 
 *   \f$\beta_c^{km},\ldots,\beta_{c+l}^{km}\f$
 * \arg gamma A pointer to an array containing the recurrence coefficients 
 *   \f$\gamma_c^{km},\ldots,\gamma_{c+l}^{km}\f$
 * \arg threshold The threshold
 */
int eval_wigner_thresh(double *x, double *y, int size, int l, double *alpha, 
  double *beta, double *gamma, double threshold);

/**
* A method used for debugging, gives the values to start the "old" three-term recurrence
* generates \f$ d^{km}_l(cos(theta)) \f$ WHERE THE DEGREE l OF THE FUNCTION IS EQUAL
* TO THE MAXIMUM OF ITS ORDERS
*
* \arg theta the argument of 
* \arg n1 the first order
* \arg n2 the second order
*
* \return the function value \f$ d^{km}_l(cos(theta)) \f$
*
**/
 double wigner_start(int n1, int n2, double theta);

#endif
