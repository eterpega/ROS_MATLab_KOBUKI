%  MATLAB Code for Mobile Robot Simulation in ROS
%  Code written for ECGR 6090/8090 Mobile Robot Sensing, Mapping and Exploration
%    Copyright (C) 2017  Andrew Willis
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software Foundation,
%    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
classdef TFManager < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tfpub
        % Create a timer for publishing tf messages
        tfpubtimer
        tftree
        tfmsgArray
        numTfMsgs
    end
    methods
        function obj = TFManager()
            obj.tfpub = rospublisher('/tf', 'tf2_msgs/TFMessage');            
            % Create a timer for publishing tf messages
            obj.tftree = rostf;
            % Buffer transformations for up to 15 seconds
            obj.tftree.BufferTime = 15;
            %frames = obj.tftree.AvailableFrames()
            %updateTime = obj.tftree.LastUpdateTime
            for idx=1:10
                obj.tfmsgArray{idx}=obj.mynewTF2Message('','',[0 0 0], [1 0 0 0]);
            end            
            obj.setMessage(1,'map', 'odom', [0 0 0], [1 0 0 0]);
            obj.setMessage(2,'map', 'odom_truth', [0 0 0], [1 0 0 0]);
            obj.numTfMsgs=2;
            obj.tfpubtimer = ExampleHelperROSTimer(0.05, {@obj.myROSTfPubTimer, obj.tfpub});            
            pause(1);
        end
        
        
        function myROSTfPubTimer(obj, ~, ~, tfpub)
            
            % Set current time stamp
            % Only do this, if the global node is active. Otherwise, calls to rostime
            % might fail.
            if robotics.ros.internal.Global.isNodeActive
                currentTime = rostime('now');
                for tfidx=1:obj.numTfMsgs
                    obj.tfmsgArray{tfidx}.Transforms(1).Header.Stamp = currentTime;
                end
            end
            
            % Publish the transformations to /tf
            if isvalid(obj.tfpub)
                for tfidx=1:obj.numTfMsgs
                    send(obj.tfpub, obj.tfmsgArray{tfidx});
                end
            end
            
        end
        
        function tf2Msg = mynewTF2Message(obj, targetFrame, sourceFrame, translation, rotation)
            %newTF2Message Create a new tf2_msgs/TFMessage with one transform
            
            tfStampedMsg = obj.mynewTransformStamped(...
                targetFrame, sourceFrame, translation, rotation);
            
            tf2Msg = rosmessage('tf2_msgs/TFMessage');
            tf2Msg.Transforms = tfStampedMsg;
        end
        
        function tfStampedMsg = mynewTransformStamped(obj, targetFrame, sourceFrame, translation, rotation)
            %newTransformStamped Create a new geometry_msgs/TransformStamped message
            
            tfStampedMsg = rosmessage('geometry_msgs/TransformStamped');
            tfStampedMsg.ChildFrameId = sourceFrame;
            tfStampedMsg.Header.FrameId = targetFrame;
            if robotics.ros.internal.Global.isNodeActive
                tfStampedMsg.Header.Stamp = rostime('now');
            end
            
            tfStampedMsg.Transform.Translation.X = translation(1);
            tfStampedMsg.Transform.Translation.Y = translation(2);
            tfStampedMsg.Transform.Translation.Z = translation(3);
            
            tfStampedMsg.Transform.Rotation.W = rotation(1);
            tfStampedMsg.Transform.Rotation.X = rotation(2);
            tfStampedMsg.Transform.Rotation.Y = rotation(3);
            tfStampedMsg.Transform.Rotation.Z = rotation(4);
        end
        
        function setMessage(obj, tfidx, targetFrame, sourceFrame, translation, rotation)
            %newTransformStamped Create a new geometry_msgs/TransformStamped message
            
            tf2Msg = obj.tfmsgArray{tfidx};
            tfStampedMsg = tf2Msg.Transforms;
            tfStampedMsg.ChildFrameId = sourceFrame;
            tfStampedMsg.Header.FrameId = targetFrame;
            if robotics.ros.internal.Global.isNodeActive
                tfStampedMsg.Header.Stamp = rostime('now');
            end
            
            tfStampedMsg.Transform.Translation.X = translation(1);
            tfStampedMsg.Transform.Translation.Y = translation(2);
            tfStampedMsg.Transform.Translation.Z = translation(3);
            
            tfStampedMsg.Transform.Rotation.W = rotation(1);
            tfStampedMsg.Transform.Rotation.X = rotation(2);
            tfStampedMsg.Transform.Rotation.Y = rotation(3);
            tfStampedMsg.Transform.Rotation.Z = rotation(4);
        end
        
    end
end
