1. 	The statistics are stored in "bsf", "generations" and "time" folder, 
	which are obtained by running 30 times on 28 benchmark functions in cec13.

	bsf
		org
			org1.mat,....,org28.mat	-- stores a variable called bsf, which is the 
			best-so-far solution for every function in the original version
		var
			var1.mat,....,var28.mat
			
	time
		org
			time1.mat,....,time28.mat	-- stores a variable called time, which is the 
			time consumed for every function in the original version
		var
			time1.mat,....,time28.mat
			
	generations
		org
			generations1.mat,....,generations28.mat	-- stores a variable called gen,
			which algorithm is selected for each run for every function.
			e.g. gen{1}(1)=1 means the first algorithm is selected in the 1st generation and 1st run. The information 
				 about the function is not contained in the variable name but in the .mat file's name.
		var
			generations1.mat,....,generations28.mat

2. 	MultiEA and its variant is implemented in main_org and main_var respectively.

3. 	There are 3 function instances in MultiEA, abcInst, cmaesInst and lshadeInst. 
	They carry the parameters and historical data for each algorithm so that the 
	algorithm instances can resume from the last generation.
	
4. 	The description of the files is as follows.

*************************************************************************

	Main function:
	main_org.m: The original version of MultiEA.
	main_var.m: A variant of MultiEA.
	
*************************************************************************

	Miscellaneous functions:
	cdf.m: 		A helper function. It takes a 1D vector as input, fit a bootstrap 
				distribution to that and returns a single sample drawn from the bootstrap distribution.
	cdf_100.m: 	A helper function. It takes a 1D vector as input, fit a bootstrap 
				distribution to that and returns 100 samples drawn from the bootstrap distribution.
	clear_nfes.m:	A function to clear previous results.
	cec13_func.mexw64: The test bed.
	
*************************************************************************	
	Algorithm functions:
*************************************************************************	
	
	abc_*:
		abc.m: The function to run abc for one generation.
		abc_InitializeABC.m: The function to initialize abc instance.
		abc_RouletteWheelSelection.m: A helper function for abc.
		abc_test.m: A function to test whether abc (generation by generation version) is implemented correctly.
		
*************************************************************************

	cmaes_*:
		cmaes.m: The function to do the computation for cmaes.
		cmaes_cmaesOnce.m: A driver function for cmaes, which runs cmaes for 
		one generation in either a resume mode or a normal mode.
		cmaes_InitializeCMAES.m: The function to initialize cmaes instance.
		cmaes_test.m: A function to test whether cmaes (generation by generation version) is implemented correctly.
		
*************************************************************************

	lshade_*:
		lshade.m: The function to do the computation for lshade.
		lshade_InitializeLSHADE.m: The function to initialize lshade instance.
		lshade_test.m: A function to test whether lshade (generation by generation version) is implemented correctly.
		others: Helper functions.

*************************************************************************	
		
		