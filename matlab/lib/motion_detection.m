function motion = motion_detection(movRGB)
%% SOME USEFUL GLOBAL VARIABLES
global method
global T1
global alpha
global T3
global R
global sigma
global T4

%% CONVERTING RGB IMAGE TO GREYSCALE IMAGE
[h, w, ~, t] = size(movRGB);
motion = zeros(h,w,t-1);
mov = zeros(h,w,t);
for k=1:t
    mov(:,:,k)=rgb2gray(movRGB(:,:,:,k)/255);
end

%% FIXED THRESHOLD METHOD
if (method==1)
    for k=2:t
        rho = mov(:,:,k)-mov(:,:,k-1);
        motion(:,:,k-1) = rho.^2 > T1;
    end
end

%% BACKGROUND MODELING METHOD
if (method==2)
    B = zeros(h,w,t-1);
    B(:,:,1) = mov(:,:,1);
    for k=2:t
        B(:,:,k) = alpha * mov(:,:,k-1) + (1-alpha)*B(:,:,k-1);
        rho = mov(:,:,k)-B(:,:,k);
        motion(:,:,k-1) = rho.^2>T3;
    end
end

%% PROBABILISTIC APPROACH
if (method==3)
    Pbgr = zeros(h,w,t-1);
    for k = 2:R
        for i=1:k-1
            Pbgr(:,:,k-1) = Pbgr(:,:,k-1) + ...
                exp(-1/(2*sigma^2)*(mov(:,:,k)-mov(:,:,k-i)).^2)/(k-1);
        end
        motion(:,:,k-1) = Pbgr(:,:,k-1) <= T4;
    end
    for k = R+1:t
        for i=1:R
            Pbgr(:,:,k-1) = Pbgr(:,:,k-1) + ...
                exp(-1/(2*sigma^2)*(mov(:,:,k)-mov(:,:,k-i)).^2)/R;
        end
        motion(:,:,k-1) = Pbgr(:,:,k-1) <= T4;
    end
end