function ft_omri_pipeline_notask(cfg)
% This code should be run on realtime computer to 1) load DICOMS beings streamed from scanner and to 2) preprocess and compute NPS response
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
key.ttl = KbName('5%');
key.s = KbName('s');


% start dicsom streaming - will require user to select folder where DICOMs
% are getting written
system('matlab -nosplash -r "run ''C:\Users\CANLab\Google Drive\fMRI_NF_study\Paradigm\updated_code\code\fieldtrip-20170217\fileio\private\system_call_dicom_stream.m'' " &');
pause(60);

timing.start_streaming=GetSecs;


AssertOpenGL;
[window, rect] = Screen('OpenWindow',0.5);
% paint black
% Screen('FillRect',window,0); %make gray
gray=GrayIndex(window,0.5);
Screen('FillRect',window,gray);
HideCursor;

%%% configure screen
dspl.screenWidth = rect(3);
dspl.screenHeight = rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;


%%% create FIXATION screen
dspl.fixation.w = Screen('OpenOffscreenWindow',0);
% paint black
Screen('FillRect',dspl.fixation.w,gray);
% add text
Screen('TextSize',dspl.fixation.w,60);
DrawFormattedText(dspl.fixation.w,'.','center','center',255);

% initialize
Screen('TextSize',window,72);
DrawFormattedText(window,'.','center','center',255);
timing.initialized = Screen('Flip',window);


% get warped NPS model
NPS=spm_read_vols(spm_vol('C:\rtFMRI\wweights_NSF_grouppred_cvpcr.img,1'));
% NPS=spm_read_vols(spm_vol([which('wweights_NSF_grouppred_cvpcr.img'),',1']));
NPS=NPS(:); %reshape for dotproduct

% wait for experimenter to press "s" before listening for TTL pulse
keycode(key.s) = 0;
while keycode(key.s) == 0
    [presstime, keycode, delta] = KbWait;
end
timing.spress = presstime;

% ready screen
Screen('TextSize',window,72);
DrawFormattedText(window,'Ready','center','center',255);
timing.readyscreen = Screen('Flip',window);
% wait for TTL pulse to trigger beginning
keycode(key.ttl) = 0;
WaitSecs(.25);
while keycode(key.ttl) == 0
    [presstime, keycode, delta] = KbWait;
end
timing.ttl=presstime;

% fixation screen
Screen('TextSize',window,72);
DrawFormattedText(window,'+','center','center',255);
timing.fixation = Screen('Flip',window);

Screen('CloseAll');

timing.delay=GetSecs;

%%% configure screen
dspl.screenWidth = rect(3);
dspl.screenHeight = rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;


% FT_OMRI_PIPELINE implements an online fMRI pre-processing pipeline
%
% Use as
%   ft_omri_pipeline(cfg)
% where cfg is a structure with configuration settings.
%
% Configuration options are
%   cfg.input            = FieldTrip buffer containing raw scans (default 'buffer://localhost:1972')
%   cfg.output           = where to write processed scans to     (default 'buffer://localhost:1973')
%   cfg.numDummy         = how many scans to ignore initially    (default 0)
%   cfg.smoothFWHM       = kernel width in mm (Full Width Half Maximum) for smoothing (default = 0 => no smoothing)
%   cfg.correctMotion 	 = flag indicating whether to correct motion artifacts (default = 1 = yes)
%   cfg.correctSliceTime = flag indicating whether to correct slice timing (default = 1 = yes)

% Copyright (C) 2010, Stefan Klanke
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$
C=hsv(7);

ft_defaults
ft_hastoolbox('spm12', 1);

if nargin < 1
    cfg = [];
end

if ~isfield(cfg, 'input')
    cfg.input = 'buffer://localhost:1972';
end

if ~isfield(cfg, 'output')
    cfg.output = 'buffer://localhost:1973';
end

if ~isfield(cfg, 'numDummy')
    cfg.numDummy = 0;			% number of dummy scans to drop
end

if ~isfield(cfg, 'smoothFWHM')
    cfg.smoothFWHM = 0;
end

if ~isfield(cfg, 'correctMotion')
    cfg.correctMotion = 1;
end

if ~isfield(cfg, 'correctSliceTime')
    cfg.correctSliceTime = 1;
end

if ~isfield(cfg, 'whichEcho')
    cfg.whichEcho = 1;
else
    if cfg.whichEcho < 1
        error '"whichEcho" configuration field must be >= 1';
    end
end

% prepare "ready" event data structure
evr = [];
evr.type = 'scan';
evr.value = 'ready';
evr.offset = 0;
evr.duration = 0;
evr.sample = 0;

history = struct('S',[], 'RRM', [], 'motion', []);

numTrial = 0;



ci=0;
% Loop this forever (until user cancels)
while 1
    clear ft_read_header
    % start by reading the header from the realtime buffer
    while 1
        try
            hdr = ft_read_header(cfg.input);
            break;
        catch
            disp(lasterror);
            disp('Waiting for header');
            pause(0.5);
        end
    end
    
    % Ok, we got the header, try to make sense out of it
    S = ft_omri_info_from_header(hdr);
    S.TR=.46;
    if isempty(S)
        warning('No protocol information found!')
        % restart loop
        pause(0.5);
        continue;
    end
    
    if cfg.whichEcho > S.numEchos
        warning('Selected echo number exceeds the number of echos in the protocol.');
        grabEcho = S.numEchos;
        fprintf(1,'Will grab echo #%i of %i\n', grabEcho, S.numEchos);
    else
        grabEcho = 1;
    end
    
    % Prepare smoothing kernels based on configuration and voxel size
    if cfg.smoothFWHM > 0
        [smKernX, smKernY, smKernZ, smOff] = ft_omri_smoothing_kernel(cfg.smoothFWHM, S.voxdim);
        smKern = convn(smKernX'*smKernY, reshape(smKernZ, 1, 1, length(smKernZ)));
    else
        smKernX = [];
        smKernY = [];
        smKernZ = [];
        smKern  = [];
        smOff   = [0 0 0];
    end
    
    niftiOut = [];
    niftiOut.dim = S.voxels;
    niftiOut.pixdim = S.voxdim;
    niftiOut.slice_duration = S.TR / S.vz;
    niftiOut.srow_x = S.mat0(1,:);
    niftiOut.srow_y = S.mat0(2,:);
    niftiOut.srow_z = S.mat0(3,:);
    
    hdrOut = [];
    hdrOut.nSamples = 0;
    hdrOut.Fs = hdr.Fs;
    if cfg.correctMotion
        hdrOut.nChans = prod(S.voxels) + 6;
    else
        hdrOut.nChans = prod(S.voxels);
    end
    hdrOut.nifti_1 = niftiOut; %encode_nifti1(niftiOut);
    
    ft_write_data(cfg.output, single([]), 'header', hdrOut);
    
    % reset motion estimates
    motEst = [];
    
    % store current info structure in history
    numTrial  = numTrial + 1;
    history(numTrial).S = S;
    disp(S)
    
    % Wait for numDummy scans (and drop them)
    fprintf(1,'Waiting for %i dummy samples to come in...\n', cfg.numDummy);
    while 1
        threshold = struct('nsamples', cfg.numDummy * S.numEchos);
        newNum = ft_poll_buffer(cfg.input, threshold, 500);
        if newNum.nsamples >= cfg.numDummy*S.numEchos
            break
        end
        pause(0.01);
    end
    
    fprintf(1,'Starting to process\n');
    numTotal  = cfg.numDummy * S.numEchos;
    numProper = 0;
    
    % Loop this as long as the experiment runs with the same protocol (= data keeps coming in)
    while 1
        % determine number of samples available in buffer / wait for more than numTotal
        threshold.nsamples = numTotal + S.numEchos - 1;
        newNum = ft_poll_buffer(cfg.input, threshold, 500);
        
        if newNum.nsamples < numTotal
            % scanning seems to have stopped - re-read header to continue with next trial
            break;
        end
        if newNum.nsamples < numTotal + S.numEchos
            % timeout -- go back to start of (inner) loop
            continue;
        end
        
        % this is necessary for ft_read_data
        hdr.nSamples = newNum.nsamples;
        
        index = (cfg.numDummy + numProper) * S.numEchos + grabEcho;
        fprintf('\nTrying to read %i. proper scan at sample index %d\n', numProper+1, index);
        GrabSampleT = tic;
        
        try
            % read data from buffer (only the last scan)
            dat = ft_read_data(cfg.input, 'header', hdr, 'begsample', index, 'endsample', index);
        catch
            warning('Problems reading data - going back to poll operation...');
            continue;
        end
        
        numProper = numProper + 1;
        numTotal  = numTotal + S.numEchos;
        
        rawScan = single(reshape(dat, S.voxels));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % motion correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.correctMotion
            doneHere = 0;
            if numProper == 1
                RRM = [];
                for i=1:length(history)
                    if isequal(history(i).S, S)
                        fprintf(1,'Will realign scans to reference model from trial %i...\n', i);
                        % protocol the same => re-use realignment reference
                        RRM = history(i).RRM;
                        break;
                    end
                end
                
                % none found - setup new one
                if isempty(RRM)
                    flags = struct('mat', S.mat0);
                    fprintf(1,'Setting up first num-dummy scan as reference volume...\n');
                    RRM = ft_omri_align_init(rawScan, flags);
                    history(numTrial).RRM = RRM;
                    curSixDof = zeros(1,6);
                    motEst = zeros(1,6);
                    procScan = single(rawScan);
                    doneHere = 1;
                end
            end
            
            if ~doneHere
                fprintf('%-30s','Registration...');
                tic;
                [RRM, M, Mabs, procScan] = ft_omri_align_scan(RRM, rawScan);
                toc
                curSixDof = hom2six(M);
                motEst = [motEst; curSixDof.*[1 1 1 180/pi 180/pi 180/pi]];
            end
        else
            procScan = single(rawScan);
            motEst = [motEst; zeros(1,6)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % slice timing correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         if cfg.correctSliceTime
        %             if numProper == 1
        %                 fprintf(1,'Initialising slice-time correction model...\n');
        %                 STM = ft_omri_slice_time_init(procScan, S.TR, S.deltaT);
        %             else
        %                 fprintf('%-30s','Slice time correction...');
        %                 tic;
        %                 [STM, procScan] = ft_omri_slice_time_apply(STM, procScan);
        %                 toc
        %             end
        %         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % smoothing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.smoothFWHM > 0
            fprintf('%-30s','Smoothing...');
            tic;
            % MATLAB convolution
            %Vsm = convn(procScan,smKern);
            %procScan = Vsm((1+smOff(1)):(end-smOff(1)), (1+smOff(2)):(end-smOff(2)), (1+smOff(3)):(end-smOff(3)));
            
            % specialised MEX file
            procScan = ft_omri_smooth_volume(single(procScan), smKernX, smKernY, smKernZ);
            
            toc
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pdat=procScan(:);
        if numProper<16 && numProper>5
            D(numProper-5,:)=pdat;
        elseif numProper>15
            std_D=(std(double(D)))';
            mean_D=mean(double(D))';
            pdat=(double(pdat)-mean_D)./std_D;
            pdat(isnan(pdat))=0;
            dat(isinf(dat))=0;
            OUT=NPS'*pdat/(norm(NPS));
            OUT=OUT/norm(pdat);
            tOut(numProper-5)=OUT;
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % done with pre-processing, write output
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if cfg.correctMotion
            procSample = [single(procScan(:)) ; single(curSixDof')];
        else
            procSample = single(procScan(:));
        end
        
        ft_write_data(cfg.output, procSample, 'header', hdrOut, 'append', true);
        
        %evr.sample = numProper;
        %ft_write_event(cfg.output, evr);
        if exist('OUT','var')
            fprintf('Pattern expression... %f\n',OUT)
        end
        fprintf('Done -- total time = %f\n', toc(GrabSampleT));
        
        if numProper<16  %if we have baseline data and can estimate deviation
            
            
        else
            
%             if any(numProper == trial_times) %make this a variable for stimulation times
%                 
%                 % find this trial
%                 ntrial=find(numProper == trial_times);
%                 timing.onsets(ntrial)=GetSecs;
%                 % find this trial in stimulation order for this run
%                 
%                 trial_start=trial_times(ntrial);
%                 
%                 % deliver stimulation
%                 timing.stimulation(ntrial) = TriggerHeat(stim_ints(ntrial));
%                 
%                 
%                 % initialize rating
%                 cursor.x = cursor.xmin; %cursor.center - cursor.start(trial,ratingtype);
%                 jit=randi(5);
%                 
%                 
%             elseif numProper==(trial_start+floor((14+jit)/.46))
%                 %             timing.rating_start(ntrial) =  WaitSecs('UntilTime',timing.stimulation(ntrial) + 14 +jit);
%                 timing.rating_start(ntrial) = GetSecs;
%                 
%                 SetMouse(dspl.xcenter,dspl.ycenter);
%                 
%                 
%                 
%                 % do animated sliding rating
%                 while 1
%                     % measure mouse movement
%                     [x, y, click] = GetMouse;
%                     % upon right click, record time, freeze for remainder of rating period
%                     if any(click(mousebuttons))
%                         % record time of click
%                         timing.response(ntrial) = GetSecs;
%                         
%                         % draw scale
%                         Screen('CopyWindow',dspl.oscale(1).w,window);
%                         % draw line to top of rating wedge
%                         Screen('DrawLine',window,[0 0 0],...
%                             cursor.x,cursor.y-(ceil(.107*(cursor.x-cursor.xmin)))-5,...
%                             cursor.x,cursor.y+10,3);
%                         Screen('Flip',window);
%                         
%                         % freeze screen
%                         break
%                     end
%                     
%                     % if run out of time
%                     if GetSecs >=  timing.rating_start(ntrial) + 8
%                         % draw scale
%                         Screen('CopyWindow',dspl.oscale(1).w,window);
%                         Screen('Flip',window);
%                         
%                         % freeze screen
%                         break
%                     end
%                     
%                     % reset mouse position
%                     SetMouse(dspl.xcenter,dspl.ycenter);
%                     
%                     % calculate displacement
%                     cursor.x = (cursor.x + x-dspl.xcenter) * TRACKBALL_MULTIPLIER;
%                     % check bounds
%                     if cursor.x > cursor.xmax
%                         cursor.x = cursor.xmax;
%                     elseif cursor.x < cursor.xmin
%                         cursor.x = cursor.xmin;
%                     end
%                     
%                     % draw scale
%                     Screen('CopyWindow',dspl.oscale(1).w,window);
%                     % add cursor
%                     Screen('FillOval',window,[128 128 128],...
%                         [[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
%                     Screen('Flip',window);
%                 end
%                 oratings(ntrial) = 100*((cursor.x-cursor.xmin)/cursor.width); %#ok
%                 
%                 
%                 % fixation
%                 %             Screen('CopyWindow',dspl.fixation.w,window);
%                 %             WaitSecs('UntilTime', timing.stimulation(ntrial) + 24);
%                 %             Screen('Flip',window);
%                 
%                 
%                 
%                 dt=GetSecs- timing.rating_start(ntrial);
%                 ci=ci+floor(dt/.46);
%                 numProper=numProper+floor(dt/.46);
%             end
            
            
            tOUT=OUT;
            tOUT=tOUT*10000; %deal with scaling issues
            if tOUT<=0
                tOUT=10;
            end

            save('C:\rtfMRI\tOut.mat','tOut')
            ci=ci+1;
        end
        % force Matlab to update the figure
        
        if ci > 847
            %             Screen('CloseAll');
            break;
        end
        
         if (GetSecs-timing.ttl)>390
        timing.finish=GetSecs;
        break;
    end
        
        
    end % while true
    
    if (GetSecs-timing.ttl)>390   %%390
        timing.finish=GetSecs;
        break;
    end
end

% Screen('CloseAll');
