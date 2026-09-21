# Bobac 现场只改参数执行说明

本文档配合 `/home/<USER>/ros2_ws/src/isaac2` 使用。原则是：脚本提前写好，现场只改 topic、坐标、夹爪和少量阈值。

## 目录

- `start_sim.sh`：启动 Isaac Sim 仿真，验证离线工程。
- `build_workspace.sh`：编译现场需要的 ROS2 包。
- `start_mapping.sh`：启动 RTAB-Map scan 建图证据链。
- `start_nav_stack.sh`：启动导航栈，不自动发目标。
- `send_goal.sh`：向 Nav2 发送目标点，默认是抓取点，可传 `x y yaw`，第 4 个参数起可追加 ROS 参数。
- `nav_then_perception.sh`：先导航到目标点，再启动轻量识别/深度/TF 位姿估计流水线。
- `start_perception_pipeline.sh`：只启动轻量识别、深度、TF 位姿估计流水线，不执行抓取。
- `start_grasp_viewer.sh`：打开识别可视化窗口。
- `run_grasp.sh`：启动识别、位姿估计、cuRobo IK 与抓取状态机。
- `execute_joint_pose.sh`：执行现场示教得到的一组固定机械臂关节角。
- `place_fixed.sh`：到达放置点后执行固定放置动作。
- `print_pose.sh`：单次输出机器人当前底盘坐标。
- `print_joints.sh`：单次输出当前右臂 `joint_1..joint_6`。
- `keyboard_base.sh`：键盘移动底盘，用于现场标点。
- `keyboard_arm.sh`：键盘移动机械臂，用于现场示教固定关节动作。
- `preflight_check.sh`：只读预检 ROS topic、相机、深度、关节、里程计。
- `save_logs.sh`：保存现场联调证据和配置快照。
- `curobo_smoke_check.sh`：只检查 cuRobo import、Bobac 配置加载和 IK solver 初始化，不移动机械臂。

## 现场优先级

1. 先跑 `preflight_check.sh`，确认 `/cmd_vel`、`/odom`、相机、深度、关节状态。
2. 建图证据跑 `start_mapping.sh`，导航栈跑 `start_nav_stack.sh`，再用 `send_goal.sh x y yaw` 发目标。
3. 到抓取点后跑 `start_perception_pipeline.sh` + `start_grasp_viewer.sh`，确认窗口里有检测框、中心点、深度点。
4. 只有相机和 TF 正常时才跑 `curobo_smoke_check.sh` 和 `run_grasp.sh`。
5. cuRobo 不通时，用 `execute_joint_pose.sh "[关节角]" duration` 执行固定示教动作。
6. 每完成一个阶段跑一次 `save_logs.sh`，这些日志可用于“系统联调、传感器标定、仿真与真机差异说明”。

## 关键参数位置

- 抓取仿真参数：`grasp_demo_pkg/config/demo_params.yaml`
- 真机适配模板：`grasp_demo_pkg/config/real_bobac_params.yaml`
- 夹爪/抓取深度：`grasp_demo_pkg/config/demo_params.yaml`
- Nav2 参数：`isaac_sim_2026/config/nav2_params_2026.yaml`

## 已验证的 7cm 精修目标发送形式

```bash
./field_ops/send_goal.sh 3.939420 -4.722604 0.094949 \
  -p initial_delay_sec:=0.5 \
  -p xy_refine_tolerance:=0.070 \
  -p yaw_refine_tolerance:=0.100 \
  -p refine_timeout_sec:=90.0 \
  -p refine_max_linear:=0.22 \
  -p refine_min_linear:=0.040
```

仿真验证结果：

```text
Goal succeeded
REFINED_RESULT pose=[3.899295, -4.726741, 0.064974]
target=[3.939420, -4.722604, 0.094949]
error_xy=0.040
error_yaw=0.030
```

## 抓取验证边界

`run_grasp.sh` 已验证能启动识别、深度估计、TF 转换、cuRobo IK、夹爪桥接和状态机；但必须在物料识别位、且 `arm_Camera` 画面能看到笔时才执行完整抓取。若 YOLO 窗口没有检测框，不要继续等抓取状态机，先用 `keyboard_base.sh`、`keyboard_arm.sh` 和 `print_pose.sh`、`print_joints.sh` 调整位置并保存点位。

## 真机切换提醒

如果真机话题不是 `/arm_camera/rgb`、`/arm_camera/depth`、`/arm_camera/camera_info`，只改 `real_bobac_params.yaml` 的相机 topic。真机不要依赖 `/material_task/report`，应使用真实标定的 `base_link_arm <- arm_Camera` TF。
