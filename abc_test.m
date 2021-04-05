%**********************************************
% This function is used to test whether the abc(generation by generation version)
% is behaving correctly.
%**********************************************
clear;close all;clc;
global bias;
bias = -1400:100:1400;
bias(find(bias == 0)) = [];

global mainInst;global abcInst;
mainInst.nfes = 0;
mainInst.d = 10;
mainInst.budget = 10000*mainInst.d;
mainInst.lb = -100;mainInst.ub = 100;
global func;
runs=30;
for func=1:1 
	mainInst.nfes=0;
	abc_InitializeABC;
	while mainInst.nfes < mainInst.budget
		abc;
	end
end
% plot(abcInst.BestCost);