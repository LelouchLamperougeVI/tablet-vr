% ArduinoTreadmill(COM)
% Interface between MATLAB and an Arduino-controlled treadmill.
% COM is the serial port name of an Arduino running a matching firmware.
% 
% ArduinoTreadmill methods:
%   reward   - Send a reward for the given duration.
%   register - Register to events.
% 
% ArduinoTreadmill Event list:
%   Frame - An input frame was detected.
%   Step  - Treadmill position changed.

% 2018-03-05. Leonardo Molina.
% 2018-09-28. Last modified.
classdef ArduinoTreadmill < Event
    properties
        % step - Encoder position.
        step = 0
        
        % frame - trigger-in count.
        frame = 0
    end
    
    properties (Dependent)
        % trigger - trigger-out pulse.
        trigger
    end
    
    properties (Constant)
        % programVersion - Program version.
        programVersion = '20180928'
    end
    
    properties (Hidden)
        % bridge - Bridge object for communication with the Arduino.
        bridge
    end
    
    properties (Access = private)
        % change - Direction the encoder last changed.
        change = 1
        
        % contactPins - Pins for detecting licks.
        contactPins = [42, 43]
        
        % delta - Position increment for each step of the rotary encoder.
        delta
        
        % encoderPins - Arduino pins where the rotary encoder is attached to.
        encoderPins = [2, 4]
        
        % encoderSteps - Number of steps in a full encoder rotation.
        encoderSteps = 500
        
        % framePin - Arduino pin will listen to state changes (e.g. frame updates from a camera).
        framePin = 20
        
        % rewardPin - Arduino pin where a reward may be triggered.
        rewardPin = 8
        
        % tapePin - Pin for IR sensing reflective tapes.
        tapePin = 3
        
        % triggerPin - Trigger-out pin to initiate external devices.
        triggerPin = 22
        
        % triggerState - Binary state of the triggerPin.
        triggerState = false
        
        % wheelRadius - Treadmill wheel's radius in cm.
        wheelRadius = 5
    end
    
    methods
        function obj = ArduinoTreadmill(com)
            % ArduinoTreadmill(com)
            % - Connect to an Arduino at the given COM port running a matching
            %   firmware.
            % - Setup rotary encoder to report forward movement.
            
            % Connect to the Arduino and setup listeners.
            obj.bridge = Bridge(com);
            obj.bridge.register('DataReceived', @obj.onDataReceived);
            obj.bridge.register('ConnectionChanged', @obj.onConnectionChanged);
            obj.bridge.verbose = false;
            obj.trigger = false;
            
            % Forward step depends on the encoder specs and wheel radius.
            obj.delta = 2 * pi / obj.encoderSteps * obj.wheelRadius;
            
            % Start Arduino.
            obj.bridge.start();
        end
        
        function delete(obj)
            % Treadmill.delete
            % Release resources.
            
            delete(obj.bridge);
        end
        
        function reward(obj, duration)
            % Treadmill.reward(duration)
            % Send a pulse for the given duration to the rewarding device (e.g. pinch-valve).
            
            obj.bridge.setPulse(obj.rewardPin, 1, 0, round(duration * 1e6), 1);
        end
        
        function triggerState = get.trigger(obj)
            triggerState = obj.triggerState;
        end
        
        function set.trigger(obj, triggerState)
            if numel(triggerState) == 1 && islogical(triggerState)
                obj.triggerState = triggerState;
                obj.bridge.setBinary(obj.triggerPin, triggerState);
            end
        end
    end
    
    methods (Access = private)
        function onConnectionChanged(obj, connected)
            % Treadmill.onConnectionChanged(connected)
            % Configure bridge when connected.
            
            if connected
                obj.bridge.getBinary(obj.framePin, 0, 0, 1);
                obj.bridge.getRotation(obj.encoderPins, 1);
                obj.bridge.getBinary(obj.tapePin, 0, 0, 1);
                obj.bridge.getContact(obj.contactPins, 25, 25, 0, 0);
            end
        end
        
        function onDataReceived(obj, data)
            % Treadmill.onDataReceived(data)
            % Bridge responded with position data.
            switch data.Pin
                case obj.encoderPins(1)
                    % Encoder detected a rotation.
                    if data.State
                        obj.change = +1;
                    else
                        obj.change = -1;
                    end
                    obj.step = obj.step + obj.change;
                    obj.invoke('Step', obj.change * obj.delta);
                case obj.framePin
                    if data.State
                        % Camera frames create an entry in the log file.
                        obj.frame = obj.frame + 1;
                        % Report current state.
                        obj.invoke('Frame', obj.frame);
                    end
                case obj.tapePin
                    % Report a change induced by the reflective tape.
                    if ~data.State
                        obj.invoke('Tape', obj.change > 0);
                    end
                case obj.contactPins(1)
                    obj.invoke('Lick', data.State);
            end
        end
    end
end