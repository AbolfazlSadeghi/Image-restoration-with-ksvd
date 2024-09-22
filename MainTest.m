%% This is a image restoration system using sparse representation
% This is main execution program and with it one functional files namely
% this is a test file demonstrating how to restoration an image,
% using learned dictionaries. The methods implemented here are the same
% one as described in "Image restoration Via Sparse and Redundant
% representations over Learned Dictionaries"

clear all; close all; clc;
disp('              Welcome to image restoration System                 ');
disp('                       By Sogol Shafizad                          ');
disp('******************************************************************');
disp('******************************************************************');
disp('******************************************************************');

%% step1: Set initial input value
Param.k=256; % number of atoms in the dictionary
Param.noise = 25; % noise level
Param.method = 'KSVD';
[ImageName,PathName] = uigetfile('*.png');
OriginalImage = im2double(imread([PathName '\' ImageName]));
s=size(OriginalImage);

%% step 2: Create a noisy image
OriginalImage = OriginalImage*255;
NoisedImage=OriginalImage+Param.noise*randn(size(OriginalImage));

if length(s)==3
    NoisedImage_R=NoisedImage(:,:,1);
    NoisedImage_G=NoisedImage(:,:,2);
    NoisedImage_B=NoisedImage(:,:,3);
    
    %% step 3: Denoise the corrupted image using learned dicitionary from corrupted image
    h=waitbar(0,'simulation in process');
    [DenoisedImage_R, timecost_R] = denoiseImage(NoisedImage_R, Param);
    [DenoisedImage_G, timecost_G] = denoiseImage(NoisedImage_G, Param);
    [DenoisedImage_B, timecost_B] = denoiseImage(NoisedImage_B, Param);
    DenoisedImage(:,:,1)=DenoisedImage_R;
    DenoisedImage(:,:,2)=DenoisedImage_G;
    DenoisedImage(:,:,3)=DenoisedImage_B;
    close(h);
    
    NoisedPSNR = 20*log10(255/sqrt(mean((NoisedImage(:)-OriginalImage(:)).^2)));
    DenoisedPSNR = 20*log10(255/sqrt(mean((DenoisedImage(:)-OriginalImage(:)).^2)));
    
    %% step4: Display the results
    OriginalImage=OriginalImage/255;
    NoisedImage=NoisedImage/255;
    DenoisedImage=DenoisedImage/255;
    
else
    
    %% step 3: Denoise the corrupted image using learned dicitionary from corrupted image
    h=waitbar(0,'simulation in process');
    [DenoisedImage, timecost] = denoiseImage(NoisedImage, Param);
    close(h);
    
    NoisedPSNR = 20*log10(255/sqrt(mean((NoisedImage(:)-OriginalImage(:)).^2)));
    DenoisedPSNR = 20*log10(255/sqrt(mean((DenoisedImage(:)-OriginalImage(:)).^2)));
    
end

figure;
subplot(1,3,1); imshow(OriginalImage,[]); title('Original clean image');
subplot(1,3,2); imshow(NoisedImage,[]); title(strcat(['Noisy image, ',num2str(NoisedPSNR),'dB']));
subplot(1,3,3); imshow(DenoisedImage,[]); title(strcat(['Denoised Image by trained dictionary, ',num2str(DenoisedPSNR),'dB']));
