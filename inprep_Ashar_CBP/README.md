This repo contains the paradigms used in the Psychological Txs for CBP study (aka OLP4CBP). The paradigms are written in MATLAB. They require 1) PsychToolbox (http://psychtoolbox.org/), and 2) installation of the finger pressure device and back bladder pressure device, for the tasks that uses those devices. Installers, controllers, and specifications for the devices are available here:  https://github.com/canlab/CANlab_data_and_equipment_private/tree/master/Equipment_and_devices (private repository, ask for access)

`run_mri_tasks.m` runs the MRI tasks in order, and `run_EEG_task.m` runs the tasks from the EEG session in order. For both of those files, edit the subject number and the session (i.e., timepoint / day) at the top, and then run the following cells. Paths will need to be edited to match the location to which you download this repository.

The tasks are as follows. Please note that the numbers at the beginning of each task name (e.g., `01`, `0X`) are not meaningful but are preserved for compatability reasons.
* `01_RestingState`: Also known as the "spontaneous pain" task. Subjects are asked once a minute to rain their back pain intensity on a VAS.
* `02_AudioPressure`: Deliver aversive sounds and thumb pressure stimuli (two intensity levels of each) in random order, followed by VAS pain rating
* `03_PRTask`: Progressive ratio task. This was administered outside of the scanner. Subjects push the space bar repeatedly for monetary reward. Key refs: Schwartz et al., 2014, Science (rodent analogue); Treadway et al., 2009 PLoS ONE)
* `04_BackPain`: The bladder task
* `05_BDMAuction`: Pain auction. Make bids on how much you value avoiding pain. This was administered outside of the scanner. Key refs: Vlaev et al., 2009, 2012.
