close all;
clearvars -except movRGB f_rate;
addpath('lib');
global MAX_FRAMES
global wx
global wy
global threshold1
global threshold2
MAX_FRAMES  = 400;
wx = 15; % window size
wy = 15;
threshold1 = 5;     % threshold on the ratio between eigenvalues, increase to add corners
threshold2 = 150;    % threshold on minimum value of eigenvalues, increase to add flat

[movRGB, f_rate] = read_video('../video/car1.avi');
save('movRGB.mat','movRGB', 'f_rate');
load('movRGB.mat');
f = figure(1);
%% CONVERTING RGB IMAGE TO GREYSCALE IMAGE
[h, w, ~, t] = size(movRGB);
mov = zeros(h+2*wy,w+2*wx,t);
motion = zeros(size(mov,1)+95,size(mov,2)+174,3,t);
[h, w, t] = size(mov);
C = mov;
mov(:,:,1) = zeroPadding(rgb2gray(movRGB(:,:,:,1)/255));
out = cell(t-1,1);
for k=2:t
%for k=2:2
    clearvars outFlow outFlat outEdge;
    currInst = zeroPadding(rgb2gray(movRGB(:,:,:,k)/255));
    mov(:,:,k) = currInst;
    prevInst = mov(:,:,k-1);    
    C = corner(currInst,'Harris');
    C = C(5:length(C),:); % Drop the corners due to the zero padding
    [Ix,Iy] = imgradientxy(currInst);
    It = (currInst-prevInst)/2;
    j1 = 1;
    j2 = 1;
    j3 = 1;
    for i = 1:size(C,1)
        Cx = C(i,1);
        Cy = C(i,2);
        if ((Cx>wx)&&(Cx<w-wx)&&(Cy>wy)&&(Cy<h-wy))
            IxWin = Ix(Cy-wy:Cy+wy,Cx-wx:Cx+wx);
            IyWin = Iy(Cy-wy:Cy+wy,Cx-wx:Cx+wx);
            ItWin = It(Cy-wy:Cy+wy,Cx-wx:Cx+wx);
            A1stCol = reshape(transpose(IxWin),(2*wx+1)*(2*wy+1),1);
            A2ndCol = reshape(transpose(IyWin),(2*wx+1)*(2*wy+1),1);
            b = reshape(transpose(ItWin),(2*wx+1)*(2*wy+1),1);
            A = [A1stCol,A2ndCol];
            ATA = transpose(A)*A;
            ATb = transpose(A)*b;
            lambda = sort(eig(ATA),'descend');
            if ((lambda(1)/lambda(2)<threshold1)&&(lambda(1)>threshold2)&&(lambda(2)>threshold2))
                outFlow(j1,:) = [Cx,Cy,transpose(ATA\(-ATb))];
                j1 = j1+1;
            else if ((lambda(1)<threshold2)&&(lambda(2)<threshold2))
                    outFlat(j2,:) = [Cx,Cy];
                    j2 = j2 + 1;
                else
                    outEdge(j3,:) = [Cx,Cy];
                    j3 = j3 + 1;
                end
            end
        end
    end
    imshow(currInst);
    hold on
    if exist('outFlow','var') && size(outFlow,1)>0
        plot(outFlow(:,1),outFlow(:,2),'g*');   % plot corners
        const = 100;    % plot vectors (a meno di uno scalare 100)
        quiver(outFlow(:,1),outFlow(:,2),const*outFlow(:,3),const*outFlow(:,4),'color','g');
    end
    if exist('outFlat','var') && size(outFlat,1)>0
        plot(outFlat(:,1),outFlat(:,2),'r*');
    end
    if exist('outEdge','var') && size(outEdge,1)>0
        plot(outEdge(:,1),outEdge(:,2),'b*');
    end
    motion(:,:,:,k)=frame2im(getframe(f));
    hold off
    %disp(strcat(int2str(j1),';',int2str(j2),';',int2str(j3),';'));
    if j1>1, out{k-1,1} = outFlow; else out{k,1} = []; end
    if j2>1, out{k-1,2} = outFlat; else out{k,2} = []; end
    if j3>1, out{k-1,3} = outEdge; else out{k,3} = []; end
end
close all
implay(motion/255, f_rate);
