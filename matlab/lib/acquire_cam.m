%sample demo for LAB5 Image and video analysis P. Zanuttigh

%set up the camera
cam = webcam;
NF = 500; %number of frmaes to acquire
cam.Resolution = '320x240';
cam.BacklightCompensation = 2; %parameters depend on the employed webcam
cam.Brightness = 80;
cam.Gain = 0;
cam.Exposure = -5;

figH = figure;
preview(cam);


fr = 10; %frame rate
vidWriter = VideoWriter('test2.mp4','MPEG-4'); %file to save
vidWriter.FrameRate = fr;
open(vidWriter);

%Acquire and store frames
%The following loop writes the acquired frames to the specified AVI file for future processing.


pause;

for index = 1:NF
    % Acquire frame for processing
    img = snapshot(cam);
    str = int2str(index);
    set(figH,'Name',str,'NumberTitle','off')
    imshow(img);
    % Write frame to video
    writeVideo(vidWriter, img);
    pause(1/fr);
end

%Clean up
%Once the connection is no longer needed, clear the associated variable.
close(vidWriter);
clear cam;
