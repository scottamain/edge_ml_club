# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""MoveNet pose classification example.

You must first complete the Google Colab to train the pose classification model:
https://g.co/coral/train-poses
And save the Colab's .tflite and .txt output files into the "models" directory.
"""

from coralkit import vision
from pycoral.utils.dataset import read_label_file
import models

MOVENET_CLASSIFY_MODEL = 'models/pose_classifier.tflite'
MOVENET_CLASSIFY_LABELS = 'models/pose_labels.txt'

pose_detector = vision.PoseDetector(models.MOVENET_MODEL)
pose_classifier = vision.PoseClassifier(MOVENET_CLASSIFY_MODEL)
labels = read_label_file(MOVENET_CLASSIFY_LABELS)

for frame in vision.get_frames():
    # Detect the body points and draw the skeleton
    pose = pose_detector.get_pose(frame)
    vision.draw_pose(frame, pose)
    # Classify different body poses
    label_id = pose_classifier.get_class(pose)
    vision.draw_label(frame, labels.get(label_id))