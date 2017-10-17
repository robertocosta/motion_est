% Image and Video Analysis (P.Zanuttigh)
% Sample script to read a video file
function [mov, f_rate] = read_video(path)
%create video object
v_obj = VideoReader(path);

% video parameters
h = v_obj.Height;
w = v_obj.Width;
f_rate = v_obj.FrameRate;
fprintf('   width: %d    height: %d   frame rate: %d \n', w, h, f_rate);


% matlab uses plenty of memory, use a limit on the number of frames
% according to the available resources to avoid out of memory errors
global MAX_FRAMES


% Read video frame by frame until available or MAX_FRAMES reached

mov = zeros(h,w,3,MAX_FRAMES); % 4D matrix to store color video
k=0; %index of last read frame

while hasFrame(v_obj) && k < MAX_FRAMES
    k=k+1;        
    vidFrame = readFrame(v_obj);
    mov(:,:,:,k) = vidFrame;
end
%{
k=0; %index of last read frame

while hasFrame(v_obj) && k < MAX_FRAMES
    k=k+1;        
    vidFrame = readFrame(v_obj);
    mov(:,:,:,k) = vidFrame;
end
%}
fprintf('%d frames read \n', k);
mov = mov(:,:,:,1:k); %delete unused matrix part to save memory

%example of empty matrix to place computation output
%out = zeros( h,w,3,k,'uint8');

% play the video
%implay(mov/255, f_rate);
