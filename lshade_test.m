%**********************************************
% This function is used to test whether the lshade(generation by generation version) is behaving correctly.
%**********************************************

clear all;close all;clc;

global mainInst;global LshadeInst;
mainInst.nfes = 0;
mainInst.d = 10;
mainInst.budget = 10000*mainInst.d;
mainInst.bsf_sol = []; 
mainInst.bsf_fit = [];
mainInst.lb = -100;mainInst.ub = 100;
global func;
func = 3;
global bias;
bias = -1400:100:1400;
bias(find(bias == 0)) = [];
lshade_InitializeLSHADE;
while mainInst.nfes < mainInst.budget
    lshade;
end
plot(LshadeInst.bsf_fit_var);