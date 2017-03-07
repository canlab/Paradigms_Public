function mixedCoords=getGamePadCoords(gamepadIndex)
% startime=getSecs;
% endtime=startime+30;

% while (getSecs<=endtime) 
maxVal=32768;
mixedCoords=[0,0];

mixedCoords(1)=Gamepad('GetAxis',gamepadIndex,1)/maxVal
% mixedCoords(2)=Gamepad('GetAxis',gamepadIndex,2)/(-1*maxVal);
mixedCoords(2)=Gamepad('GetAxis',gamepadIndex,2)/(maxVal)
% end