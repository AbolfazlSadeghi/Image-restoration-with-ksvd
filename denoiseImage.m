function [IOut,timecost] = denoiseImage(Image,Param)
%% step 1: input value
[m,n] = size(Image);
C = 1.15;
bb = 8; % block size
maxNumBlocksToTrainOn = 1000;
sigma = Param.noise;
K = Param.k;

%% step 2:train a dictionary on blocks from the noisy image

if(prod([m,n]-bb+1)> maxNumBlocksToTrainOn)
    randPermutation =  randperm(prod([m,n]-bb+1));
    selectedBlocks = randPermutation(1:maxNumBlocksToTrainOn);
    
    blkMatrix = zeros(bb^2,maxNumBlocksToTrainOn);
    for i = 1:maxNumBlocksToTrainOn
        [row,col] = ind2sub(size(Image)-bb+1,selectedBlocks(i));
        currBlock = Image(row:row+bb-1,col:col+bb-1);
        blkMatrix(:,i) = currBlock(:);
    end
else
    blkMatrix = im2col(Image,[bb,bb],'sliding');
end

param.K = K;
param.I= 1:K;
param.itN = 10;
param.errorGoal = sigma*C;

%% step 3: make initial dictionary
Pn=ceil(sqrt(K));
DCT=zeros(bb,Pn);
for k=0:1:Pn-1,
    V=cos([0:1:bb-1]'*k*pi/Pn);
    if k>0, V=V-mean(V); end;
    DCT(:,k+1)=V/norm(V);
end;
DCT=kron(DCT,DCT);

param.initialDictionary = DCT(:,1:param.K );

%reducedc
vecOfMeans = mean(blkMatrix);
blkMatrix = blkMatrix-ones(size(blkMatrix,1),1)*vecOfMeans;

time_start = clock;

[Dictionary] = KSVD01(blkMatrix,param);

time_end = clock;
timecost = etime(time_end,time_start);

% denoise the image using the resulted dictionary
errT = sigma*C;

blocks = im2col(Image,[bb,bb],'sliding');
idx = 1:size(blocks,2);

% go with jumps of 30000
for jj = 1:30000:size(blocks,2)
    
    jumpSize = min(jj+30000-1,size(blocks,2));
    
    %reduceDC
    vecOfMeans = mean(blocks(:,jj:jumpSize));
    blocks(:,jj:jumpSize) = blocks(:,jj:jumpSize) - repmat(vecOfMeans,size(blocks,1),1);
    
    
    Coefs = OMPerr(Dictionary,blocks(:,jj:jumpSize),errT);
    
    %reducedc
    blocks(:,jj:jumpSize)= Dictionary*Coefs + ones(size(blocks,1),1) * vecOfMeans;
    
end

count = 1;
Weight = zeros(m,n);
IMout = zeros(m,n);
[rows,cols] = ind2sub(size(Image)-bb+1,idx);
for i  = 1:length(cols)
    col = cols(i); row = rows(i);
    block =reshape(blocks(:,count),[bb,bb]);
    IMout(row:row+bb-1,col:col+bb-1)=IMout(row:row+bb-1,col:col+bb-1)+block;
    Weight(row:row+bb-1,col:col+bb-1)=Weight(row:row+bb-1,col:col+bb-1)+ones(bb);
    count = count+1;
end;

IOut = (Image+0.034*sigma*IMout)./(1+0.034*sigma*Weight);


