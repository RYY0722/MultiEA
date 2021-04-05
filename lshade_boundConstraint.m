%******************************************************
% Ref: 	Ryoji Tanabe and Alex Fukunaga: Improving the Search Performance of SHADE 
% 		Using Linear Population Size Reduction,  Proc. IEEE Congress on 
% 		Evolutionary Computation (CEC-2014), Beijing, July, 2014.
%
% Note: The code is downloaded from https://sites.google.com/site/tanaberyoji/software
% 		(LSHADE1.0.1_CEC2014_Octave-Matlab.zip)
%				
%		This is a helper function for lshade and is not modified.
%******************************************************


function vi = lshade_boundConstraint (vi, pop, lu)

% if the boundary constraint is violated, set the value to be the middle
% of the previous value and the bound
%
% Version: 1.1   Date: 11/20/2007
% Written by Jingqiao Zhang, jingqiao@gmail.com

%vi = boundConstraint(vi, pop, lu);
[NP, D] = size(pop);  % the population size and the problem's dimension

%% check the lower bound
xl = repmat(lu(1, :), NP, 1); %Ryy: 100*10, every element is min_region = -100
pos = vi < xl;
vi(pos) = (pop(pos) + xl(pos)) / 2;

%% check the upper bound
xu = repmat(lu(2, :), NP, 1);
pos = vi > xu;
vi(pos) = (pop(pos) + xu(pos)) / 2;