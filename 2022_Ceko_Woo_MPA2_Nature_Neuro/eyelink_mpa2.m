function eyelink_mpa2(data, varargin)

% eyelink_mpa2(data, varargin)
% 
% varargin: 'Init', 'Shutdown'

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            
            case 'Init'
                commandwindow;
                dummymode=0;
                try
                    edfFile = sprintf('%d.EDF',data.subject);
                    % STEP 2
                    % Open a graphics window on the main screen
                    [window1, wRect]=Screen('OpenWindow', whichScreen, 0,[],32,2);
                    Screen(window1,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    % STEP 3
                    % Provide Eyelink with details about the graphics environment
                    % and perform some initializations. The information is returned
                    % in a structure that also contains useful defaults
                    % and control codes (e.g. tracker state bit and Eyelink key values).
                    el=EyelinkInitDefaults(window1);
                    % STEP 4
                    % Initialization of the connection with the Eyelink Gazetracker.
                    % exit program if this fails.
                    if ~EyelinkInit(dummymode)
                        fprintf('Eyelink Init aborted. Cannot connect to Eyelink\n');
                        % cleanup;
                        % function cleanup
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    % check the version of the eye tracker & host software
                    %         sw_version = 0;
                    [v, vs]=Eyelink('GetTrackerVersion');
                    %         fprintf('Running experiment on a ''%s''tracker.\n', vs );
                    %         fprintf('tracker version v=%d\n', v);
                    
                    % open file to record data to
                    eye = Eyelink('Openfile', edfFile);
                    if eye~=0
                        fprintf('Cannot create EDF file ''%s'' ', edffilename);
                        % cleanup;
                        % function cleanup
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    
                    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
                    [width, height]=Screen('WindowSize', whichScreen);
                    
                    % STEP 5
                    % SET UP TRACKER CONFIGURATION
                    % Setting the proper recording resolution, proper calibration type,
                    % as well as the data file content;
                    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
                    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
                    % set calibration type.
                    Eyelink('command', 'calibration_type = HV9');
                    % set parser (conservative saccade thresholds)
                    
                    % set EDF file contents using the file_sample_data and
                    % file-event_filter commands
                    % set link data thtough link_sample_data and link_event_filter
                    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    
                    % check the software version
                    % add "HTARGET" to record possible target data for EyeLink Remote
                    if v>=4
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
                    else
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
                    end
                    
                    
                    % allow to use the big button on the eyelink gamepad to accept the
                    % calibration/drift correction target
                    Eyelink('command', 'button_function 5 "accept_target_fixation"');
                    
                    % make sure we're still connected.
                    if Eyelink('IsConnected')~=1 && dummymode == 0
                        fprintf('not connected at step 5, clean up\n');
                        % cleanup;
                        % function cleanup
                        Eyelink('Shutdown');
                        Screen('CloseAll');
                        commandwindow;
                        return;
                    end
                    
                    % STEP 6
                    % Calibrate the eye tracker
                    % setup the proper calibration foreground and background colors
                    el.backgroundcolour = [125 125 125]; %changed to gray
                    el.calibrationtargetcolour = [255 255 255];
                    
                    % parameters are in frequency, volume, and duration
                    % set the second value in each line to 0 to turn off the sound
                    el.cal_target_beep=[600 0.5 0.05];
                    el.drift_correction_target_beep=[600 0.5 0.05];
                    el.calibration_failed_beep=[400 0.5 0.25];
                    el.calibration_success_beep=[800 0.5 0.25];
                    el.drift_correction_failed_beep=[400 0.5 0.25];
                    el.drift_correction_success_beep=[800 0.5 0.25];
                    
                    %Setting target size as recommended by Marcu at Eyelink
                    el.calibrationtargetsize = 1.8;
                    el.calibrationtargetwidth = 0.2;
                    
                    % you must call this function to apply the changes from above
                    EyelinkUpdateDefaults(el);
                    
                    % Hide the mouse cursor;
                    Screen('HideCursorHelper', window1);
                    EyelinkDoTrackerSetup(el);
                catch exc
                    %this "catch" section executes in case of an error in the "try" section
                    %above.  Importantly, it closes the onscreen window if its open.
                    % cleanup;
                    % function cleanup
                    getReport(exc,'extended')
                    disp('EYELINK CAUGHT')
                    Eyelink('Shutdown');
                    Screen('CloseAll');
                    commandwindow;
                end
                
            case 'Shutdown'
                
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.5);
                Eyelink('CloseFile');
                % download data file
                try
                    fprintf('Receiving data file ''%s''\n', edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                end
                % STEP 9
                % cleanup;
                % function cleanup
                Eyelink('Shutdown');
                
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end


