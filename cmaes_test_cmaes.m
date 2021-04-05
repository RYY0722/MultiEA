%**********************************************
% This function is used to test whether the cmaes(generation by generation version) is behaving correctly.
%**********************************************

clear all;close all;clc;
global bias;
bias = -1400:100:1400;
bias(find(bias == 0)) = [];
global mainInst;global cmaesInst;global abcInst;global LshadeInst;
mainInst.nfes = 0;
mainInst.d = 10;
mainInst.budget = 10000*mainInst.d;
mainInst.bsf_sol = [];
mainInst.bsf_fit = [];
mainInst.lb = -100;mainInst.ub = 100;
global func;
func = 1;
global cmaesInst;
cmaes_InitializeCMAES();
      while mainInst.nfes < mainInst.budget
          cmaes_cmaesOnce(true);
      end
plot(cmaesInst.fmin);