#!/usr/bin/env python3
import math, sys, rospy, tf
if len(sys.argv) != 4:
    print('用法: check_nav_error_once.py 目标x 目标y 目标theta_rad')
    sys.exit(2)
tx, ty, tt = map(float, sys.argv[1:4])
rospy.init_node('check_nav_error_once', anonymous=True)
l = tf.TransformListener()
l.waitForTransform('map', 'base_footprint', rospy.Time(0), rospy.Duration(5.0))
p, q = l.lookupTransform('map', 'base_footprint', rospy.Time(0))
yaw = tf.transformations.euler_from_quaternion(q)[2]
pos_err = math.hypot(p[0]-tx, p[1]-ty)
yaw_err = math.atan2(math.sin(yaw-tt), math.cos(yaw-tt))
print('当前: x=%.3f y=%.3f theta=%.3f yaw=%.1fdeg' % (p[0], p[1], yaw, math.degrees(yaw)))
print('目标: x=%.3f y=%.3f theta=%.3f yaw=%.1fdeg' % (tx, ty, tt, math.degrees(tt)))
print('位置误差=%.3fm / %.1fcm, 朝向误差=%.3frad / %.1fdeg' % (pos_err, pos_err*100, yaw_err, math.degrees(yaw_err)))
