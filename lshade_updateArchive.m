%******************************************************
% Ref: 
%		Ryoji Tanabe and Alex Fukunaga: Improving the Search Performance of SHADE 
% 		Using Linear Population Size Reduction,  Proc. IEEE Congress on 
%		Evolutionary Computation (CEC-2014), Beijing, July, 2014.
%
% Note: The code is downloaded from https://sites.google.com/site/tanaberyoji/software
% 		(LSHADE1.0.1_CEC2014_Octave-Matlab.zip)
%				
%		This is a helper function for lshade and is not modified.
%******************************************************

function archive = updateArchive(archive, pop, funvalue)
% Update the archive with input solutions
%   Step 1: Add new solution to the archive
%   Step 2: Remove duplicate elements
%   Step 3: If necessary, randomly remove some solutions to maintain the archive size
%
% Version: 1.1   Date: 2008/04/02
% Written by Jingqiao Zhang (jingqiao@gmail.com)
%rand("seed",23);
%archive = updateArchive(archive, popold(I == 1, :), fitness(I == 1));
if archive.NP == 0, return; end

if size(pop, 1) ~= size(funvalue,1), error('check it'); end

% Method 2: Remove duplicate elements
popAll = [archive.pop; pop ]; %Ryy: archive += better children
funvalues = [archive.funvalues; funvalue ];
[dummy IX]= unique(popAll, 'rows');
if length(IX) < size(popAll, 1) % There exist some duplicate solutions
  popAll = popAll(IX, :);  
  funvalues = funvalues(IX, :);
end

if size(popAll, 1) <= archive.NP   % add all new individuals
  archive.pop = popAll;
  archive.funvalues = funvalues;
else                % randomly remove some solutions
  rndpos = randperm(size(popAll, 1)); % equivelent to "randperm"; shuffle the indices of popAll, eg. [1,3,2,5,4] if size(popAll, 1) = 5
  rndpos = rndpos(1 : archive.NP);
  
  archive.pop = popAll(rndpos, :);
  archive.funvalues = funvalues(rndpos, :);
end
