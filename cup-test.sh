export TESTCASE="cup-test"
export PROJECT_ROOT=$(pwd) 
cd $PROJECT_ROOT
python src/obj_pose_track.py \
--rgb_seq_path $PROJECT_ROOT/$TESTCASE/rgb \
--depth_seq_path $PROJECT_ROOT/$TESTCASE/depth \
--mesh_path $PROJECT_ROOT/$TESTCASE/mesh/final_mesh.obj \
--init_mask_path $PROJECT_ROOT/$TESTCASE/masks/frame_00021.png \
--pose_output_path $PROJECT_ROOT/$TESTCASE/pose.npy \
--mask_visualization_path $PROJECT_ROOT/$TESTCASE/mask_visualization \
--bbox_visualization_path $PROJECT_ROOT/$TESTCASE/bbox_visualization \
--pose_visualization_path $PROJECT_ROOT/$TESTCASE/pose_visualization \
--cam_K_txt $PROJECT_ROOT/$TESTCASE/cam_K.txt \
--activate_2d_tracker \
--apply_scale 1 \
--est_refine_iter 10 \
--track_refine_iter 3