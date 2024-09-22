function [D,X] = K_DictUpdate02(Y,D,X)

% K_DictUpdate02 is the dictionary update function in K-SVD.
% Given the initial dictionary D, initial sparse coefficient matrix X and
% the traning data matrix Y, this function produces the updated D and X
% by K-SVD algorithm.

%% update dictionary
jPerm = 1:size(D,2);
D = findBetterDictionary(Y,D,X,jPerm);

function [D,X] = findBetterDictionary(Y,D,X,jPerm)
d = size(D,2);
Omega = X~=0;
for j=jPerm
    % compute relevant data
    jC = [1:j-1 j+1:d];
    DI = D(:,jC);
    XI = X(jC,:);
    YI = Y - DI*XI;
    
    % update codeword
    OmegaJ = Omega(j,:);
    YIJ = YI(:,OmegaJ);
    [Uj,Sj,Vj] = svds(YIJ,1);
    D(:,j) = Uj;
    X(j,OmegaJ) = Sj*Vj';
end
return;