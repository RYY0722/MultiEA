%*****************************************
%
% This function clear the nfes_multiEA_var.mat.
% eg. If you want to run function 12-15 and you want to 
% discard the results that you obtained previously(if any),
% change the first line to "for i = 12:15"
% 
%*****************************************

for i=1:30
    nfes_multiEA_var{i}=zeros(1,30);
end
save nfes_multiEA_var.mat nfes_multiEA_var;
