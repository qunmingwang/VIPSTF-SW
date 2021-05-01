%%%%This is the code for VIPSTF-SW produced by Dr Qunming Wang; Email: wqm11111@126.com
%%%%Copyright belong to Qunming Wang
%%%%When using the code, please cite the fowllowing papers
%%%%Q. Wang, Y. Tang, X. Tong, P. M. Atkinson. Virtual image pair-based spatio-temporal fusion. Remote Sensing of Environment, 2020, 249: 112009.

clear all;

%%%known Landsat-MODIS image pairs
load L1.mat; load M1.mat 
load L2.mat; load M2.mat
load L3.mat; load M3.mat
load L4.mat; load M4.mat

load L0.mat; load M0.mat  %%%Landsat-MODIS image pair at the prediction time

Landsat_known(:,:,:,1)=L1; Modis_known(:,:,:,1)=M1;
Landsat_known(:,:,:,2)=L2; Modis_known(:,:,:,2)=M2;
Landsat_known(:,:,:,3)=L3; Modis_known(:,:,:,3)=M3;
Landsat_known(:,:,:,4)=L4; Modis_known(:,:,:,4)=M4;
Landsat_predict=L0; Modis_predict=M0;

[Number_row,Number_col,Number_bands,Number_images]=size(Landsat_known);

s=20;

%%%%linear fitting

Modis_predict_imresize=imresize(Modis_predict,s,'bicubic');
Modis_predict_reshape=reshape(Modis_predict_imresize,[Number_row*Number_col Number_bands]);

for i=1:Number_images
    Modis_known_imresize(:,:,:,i)=imresize(Modis_known(:,:,:,i),s,'bicubic');
    Modis_known_reshape(:,:,i)=reshape(Modis_known_imresize(:,:,:,i),[Number_row*Number_col Number_bands]);  
end

[a,b,r]=LinearRegression_multiple(Modis_predict_reshape,Modis_known_reshape);   %%%regression

w0=32;
N_S=30;
A=(2*w0+1)/2;
B1=3;
B2=4;

Z1=zeros(size(Landsat_predict));
Z2=zeros(size(Landsat_predict));
Z0=zeros(size(Landsat_predict));
RB=zeros(size(Landsat_predict));

for k=1:Number_bands
    for i=1:Number_images
        Z1(:,:,k)=Z1(:,:,k)+a(i,k)*Landsat_known(:,:,k,i);
    end
    Z2(:,:,k)=Z1(:,:,k)+b(k);
    RB(:,:,k)=reshape(r(:,k),Number_row,Number_col);
    Z2_interpolated(:,:,k)=STARFM_fast_2016_v2(Z0(:,:,k),Z0(:,:,k),RB(:,:,k),Z1(:,:,B1),Z1(:,:,B2),w0,N_S,A);
end

VIPSTF_SW=Z2+Z2_interpolated;

FalseColorf=VIPSTF_SW(:,:,[4 3 2]);xf=imadjust(FalseColorf,stretchlim(FalseColorf),[]);figure,imshow(xf);
