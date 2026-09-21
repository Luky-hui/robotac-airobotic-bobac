#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
export ISAAC_SIM_ROOT="${ISAAC_SIM_ROOT:-/home/<USER>/isaac-sim-4.5.0}"

python3 - "$PKG" "$ISAAC_SIM_ROOT" <<'PY'
import os
import sys
import traceback
from pathlib import Path

pkg = Path(sys.argv[1])
isaac_root = Path(sys.argv[2])

for path in (
    pkg / "isaac_sim_2026" / "curobo" / "src",
    isaac_root / "kit" / "python" / "lib" / "python3.10" / "site-packages",
    isaac_root / "python_packages",
    isaac_root / "exts" / "omni.pip.compute" / "pip_prebundle",
    isaac_root / "exts" / "omni.pip.cloud" / "pip_prebundle",
):
    p = str(path)
    if path.exists() and p not in sys.path:
        sys.path.insert(0, p)

cfg = pkg / "isaac_sim_2026" / "config" / "bobac_eco65_right_tcp.yml"
if not cfg.exists():
    raise SystemExit(f"missing robot cfg: {cfg}")

print(f"robot_cfg_path={cfg}")
print(f"CUDA_HOME={os.environ.get('CUDA_HOME')}")

try:
    from curobo.geom.sdf.world import CollisionCheckerType
    from curobo.geom.types import WorldConfig
    from curobo.types.base import TensorDeviceType
    from curobo.util_file import load_yaml
    from curobo.wrap.reacher.ik_solver import IKSolver, IKSolverConfig

    tensor_args = TensorDeviceType()
    robot_cfg = load_yaml(str(cfg))["robot_cfg"]
    world_cfg = WorldConfig.from_dict(
        {"cuboid": {"far_dummy": {"dims": [0.01, 0.01, 0.01], "pose": [100, 100, 100, 1, 0, 0, 0]}}}
    )
    ik_config = IKSolverConfig.load_from_robot_config(
        robot_cfg,
        world_cfg,
        position_threshold=0.015,
        rotation_threshold=0.20,
        num_seeds=8,
        self_collision_check=True,
        self_collision_opt=True,
        tensor_args=tensor_args,
        use_cuda_graph=False,
        collision_checker_type=CollisionCheckerType.PRIMITIVE,
    )
    solver = IKSolver(ik_config)
    print("CUROBO_SMOKE_OK=True")
    print("curobo_import_ok=True")
    print("curobo_solver_ok=True")
    print(f"kinematic_joint_names={solver.kinematics.joint_names}")
    print(f"base_link={robot_cfg['kinematics'].get('base_link')}")
    print(f"ee_link={robot_cfg['kinematics'].get('ee_link')}")
except Exception as exc:
    print("CUROBO_SMOKE_OK=False")
    print(f"error_type={type(exc).__name__}")
    print(f"error={exc}")
    print("hint=If this appears on the real robot, skip cuRobo and use fixed taught joint poses.")
    traceback.print_exc(limit=3)
    raise SystemExit(2)
PY
