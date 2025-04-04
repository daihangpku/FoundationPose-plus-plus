# FoundationPose++: Simple Tricks Boost FoundationPose Performance in High-Dynamic Scenes

### 该文档旨在介绍FoundationPose++的工作流程及输出，帮助读者能够快速上手运行项目

---

## FoundationPose++概述

For the 6 degrees of freedom in 6D pose (x, y, z, roll, pitch, yaw), this method use common 2D trackers like Cutie, Samurai, OSTrack, etc., for xy. For z, directly take the depth at (x, y). For (roll, pitch, yaw),  a Kalman Filter is used for tracking. This is a very simple and engineering-oriented trick, but the final results are outstanding. 

## 测试数据
Your testcase data should be formatted like:
```
$PROJECT_ROOT/$TESTCASE
└── color
    ├── 0.png
    ├── 1.png
    └── ...
└── depth
    ├── 0.png
    ├── 1.png
    └── ...
└── mesh
    ├── mesh.obj/mesh.stl/etc.
```
There should be an RGB image file and a corresponding depth file for each frame, as well as a mesh file of the object, following [FoundationPose](https://github.com/NVlabs/FoundationPose) data format. You can check out [FoundationPose_manual](https://github.com/030422Lee/FoundationPose_manual) if you are not familiar with FoundationPose.

Since we use trimesh to process mesh files, the mesh format can be STL, OBJ, etc.

## 运行demo

We provide our demo of lego_20fps in Google Drive: https://drive.google.com/file/d/1oN5IZHKlb06hEol6akwx1ibCiVcJBuuI/view?usp=sharing

Download and add it to your project_root directory

The mask of the first frame has been included in the link. You can run the following scripts to check the results.

```
export TESTCASE="lego_20fps"
cd $PROJECT_ROOT   # Path to the project root directory
python src/obj_pose_track.py \
--rgb_seq_path $PROJECT_ROOT/$TESTCASE/color \
--depth_seq_path $PROJECT_ROOT/$TESTCASE/depth \
--mesh_path $PROJECT_ROOT/$TESTCASE/mesh/1x4.stl \
--init_mask_path $PROJECT_ROOT/$TESTCASE/0_mask.png \
--pose_output_path $PROJECT_ROOT/$TESTCASE/pose.npy \
--mask_visualization_path $PROJECT_ROOT/$TESTCASE/mask_visualization \
--bbox_visualization_path $PROJECT_ROOT/$TESTCASE/bbox_visualization \
--pose_visualization_path $PROJECT_ROOT/$TESTCASE/pose_visualization \
--cam_K "[[426.8704833984375, 0.0, 423.89471435546875], [0.0, 426.4277648925781, 243.5056915283203], [0.0, 0.0, 1.0]]" \
--activate_2d_tracker \
--apply_scale 0.01 \
--force_apply_color \
--apply_color "[0, 159, 237]" \
--est_refine_iter 10 \
--track_refine_iter 3
```

After successfully running, you will find the results in $PROJECT_ROOT/$TESTCASE/pose_visualization.



## 参数说明

```--rgb_seq_path```              
type=str, default="/workspace/yanwenhao/detection/test_case2/color"  

```--depth_seq_path ```  
          type=str, default="/workspace/yanwenhao/detection/test_case2/depth"  

```--mesh_path```           
       type=str, default="/workspace/yanwenhao/detection/test_case2/mesh/1x4.stl"  

```--init_mask_path```  
           type=str, default="/workspace/yanwenhao/detection/FoundationPose++/masks/0_m.jpg"  

```--pose_output_path```  
        type=str, default="/workspace/yanwenhao/detection/FoundationPose++/pose.npy"  

```--mask_visualization_path```  
   type=str, default="/workspace/yanwenhao/detection/FoundationPose++/masks_visualization"  

```--bbox_visualization_path```  
  type=str, default="/workspace/yanwenhao/detection/FoundationPose++/bbox_visualization"  

```--pose_visualization_path```  
  type=str, default="/workspace/yanwenhao/detection/FoundationPose++/pose_visualization"  

```--cam_K_txt```  
                    type=str, default="/workspace/yanwenhao/detection/test_case2/cam_K.txt" (txtfile) 
                           **Camera intrinsic parameters**

```--est_refine_iter```  
          type=int, default=10  
                           help="FoundationPose initial refine iterations, see https://github.com/NVlabs/FoundationPose"  

```--track_refine_iter```  
        type=int, default=5  
                           help="FoundationPose tracking refine iterations, see https://github.com/NVlabs/FoundationPose"  

```--activate_2d_tracker```  
      action='store_true'  
                           **Activate 2D tracker**  

```--activate_kalman_filter```  
   action='store_true'  
                           **Activate Kalman filter**  

```--kf_measurement_noise_scale```  
  type=float, default=0.05  
                           **The scale of measurement noise relative to prediction in Kalman** **filter, greater value means more filtering.**  
                                 **Only effective if activate_kalman_filter is enabled** 

```--apply_scale```  
              type=float, default=0.01  
                           **Mesh scale factor in meters (1.0 means no scaling), commonly use 0.01** 

```--force_apply_color```  
        action='store_true'  
                           **Force a color for colorless mesh"** 

```--apply_color```  
              type=json.loads, default="[0, 159, 237]"  
                           **RGB color to apply, in format 'r,g,b'. Only effective if force_apply_color is enabled** 


*To get more infos , please view [obj_pose_track.py](./src/obj_pose_track.py)*


## Inference with your own data
### Get the object mask of the first frame to initialize the 2D tracker
This process is to get the mask of the first frame, to help FoundationPose better locate the object during tracking. We use a 2-stage method (Qwen-VL + SAM-HQ) as an example to extract the mask, you can use any other tools to get the mask.


#### Use Qwen-VL to extract the bounding box [OPTIONAL]

We use Qwen-VL to extract the bounding box, you can use any other tools to get it or directly provide bounding box area without running QwenVL using commands like `BOUNDING_BOX_POSITION=[640, 419, 190, 37]`. 

```
# start Qwen-VL webapi
cd $PROJECT_ROOT
python src/WebAPI/qwen2_vl_api.py --weight_path $PROJECT_ROOT/Qwen2-VL/weights &

# use Qwen-VL to get the bbox of the object
cd $PROJECT_ROOT
BOUNDING_BOX_POSITION=$(python src/utils/obj_bbox.py \
    --frame_path $PROJECT_ROOT/$TESTCASE/color/0.png \
    --visualize_path $PROJECT_ROOT/$TESTCASE/0_bbox.png \
    --object_name $DESCRIPTION_OF_THE_OBJECT \
    --reference_img_path $PATH_OF_REFERENCE_IMAGE)
```

#### Use SAM-HQ to extract the mask [OPTIONAL]
We use SAM-HQ to extract the mask, you can use any other tools to get it or directly provide it in the path of `$PROJECT_ROOT/$TESTCASE/0_mask.png`. 
```
# start SAM webapi
python src/WebAPI/hq_sam_api.py --checkpoint_path $PROJECT_ROOT/sam-hq/pretrained_checkpoints/sam_hq_vit_h.pth &

# get the mask of object in the first frame
python src/utils/obj_mask.py  \
    --frame_path $PROJECT_ROOT/$TESTCASE/color/0.png \
    --bbox_xywh "$BOUNDING_BOX_POSITION" \
    --output_mask_path $PROJECT_ROOT/$TESTCASE/0_mask.png
```

`$DESCRIPTION_OF_THE_OBJECT`: the description of an object to help QwenVL anchor box positions, better in Chinese.

`$PATH_OF_REFERENCE_IMAGE`: you can provide what the object looks like to help QwenVL anchor box positions more precisely.

### 6D Pose Track Inference
Run the following script to track 6D Pose, the results will be visualized in `$PROJECT_ROOT/pose_visualization`.
```
cd $PROJECT_ROOT
python src/obj_pose_track.py \
--rgb_seq_path $PROJECT_ROOT/$TESTCASE/color \
--depth_seq_path $PROJECT_ROOT/$TESTCASE/depth \
--mesh_path $PROJECT_ROOT/$TESTCASE/mesh/1x4.stl \
--init_mask_path $PROJECT_ROOT/$TESTCASE/0_mask.png \
--pose_output_path $PROJECT_ROOT/$TESTCASE/pose.npy \
--mask_visualization_path $PROJECT_ROOT/$TESTCASE/mask_visualization \
--bbox_visualization_path $PROJECT_ROOT/$TESTCASE/bbox_visualization \
--pose_visualization_path $PROJECT_ROOT/$TESTCASE/pose_visualization \
--activate_2d_tracker \
--activate_kalman_filter \
--kf_measurement_noise_scale 0.05 \
--apply_scale 0.01
```



For finer grained kalman filter settings, see [kalman_filter_6d.py](./src/utils/kalman_filter_6d.py).

Use `force_apply_color` and `apply_color` to select a color for the mesh. Regarding other original [FoundationPose](https://github.com/030422Lee/FoundationPose_manual) parameters, checkout https://github.com/NVlabs/FoundationPose/issues/44#issuecomment-2048141043 if you have further problems or get unexpected results. 