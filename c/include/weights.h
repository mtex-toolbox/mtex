#ifndef WEIGHTS_H
#define WEIGHTS_H
#include "api.h"

/**
 * Computes the quadrature weights for a Clenshaw-Curtis-type rule to
 * evaluate Wigner-d functions on nodes from the method \see getNodes(bw,j)
 * on the open interval (0,\pi) according the Kostelec/Rockmore "SOFT" 
 *
 * \arg bw the bandwidth
 * \return the (2*bw)-many weights 
 */ 
double *getWeights(int bw);
/**
 * Computes the quadrature weights for a Clenshaw-Curtis rule to
 * evaluate Wigner-d functions on nodes from the method \see getCCNodes(bw,j)
 * on the  interval [0,\pi] 
 *
 * \arg bw the bandwidth
 * \return the (2*bw+1)-many weights 
 */ 
double *getCCWeights(int bw);
/**
 * Computes the j-th node on an equispaced grid that matches the 
 * Clenshaw-Curtis-type rule to evaluate Wigner-d functions on the open 
 * interval (0,\pi) according the Kostelec/Rockmore "SOFT" \see getWeights(bw)
 *
 * \arg bw the bandwidth
 * \arg j the number of the node on the equispaced grid
 * \return one node 
 */ 
double getNodes(int bw,int j);
/**
 * Computes the j-th node on an equispaced grid that matches the 
 * Clenshaw-Curtis rule to evaluate Wigner-d functions on the  
 * interval [0,\pi] from \see getCCWeights(bw)
 *
 * \arg bw the bandwidth
 * \arg j the number of the node on the equispaced grid
 * \return one node 
 */ 
double getCCNodes(int bw,int j);
/**
 * Computes the j-th node a_j on an equispaced grid that matches the 
 * quadrature rule to evaluate exponential functions \f$ e^{i\cdot a} \f$ 
 * where a \in [0,2\pi] 
 *
 * \arg bw the bandwidth
 * \arg j the number of the node a_j on the equispaced grid
 * \return the node a 
 */ 
double getEulerNodes(int bw,int j);

#endif
