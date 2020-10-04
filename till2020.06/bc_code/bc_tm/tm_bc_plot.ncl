;;;空间相关系数绘图程序
;;;采用前一步输出的空间相关系数场
;3.16修改为带regcm的部分 3x2
;3.29添加error_test部分，将修正效果超过原本误差一半的地方用点打出 (弃用)
;3.31修改 处理RMSE 配合tm_bc_plot_preprocess.ncl
;4.11 移动bc文件位置 修改路径 使用/mnt/
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;>>>read CN05.1&WRF cor data   
;####################################在文件读取中设置参数##################################
;  /mnt/D/DATAFILE/NCLDATA/
  ; f_tm_bc_cclm = addfile("~/practice/bc_data/temporary_data/bc_tm/bc_tm_cclm_02"+".nc", "r")
  ; f_tm_bc_wrf  = addfile("~/practice/bc_data/temporary_data/bc_tm/bc_tm_wrf_02"+".nc", "r")
  ; f_tm_bc_regcm = addfile("~/practice/bc_data/temporary_data/bc_tm/bc_tm_regcm_02"+".nc", "r")
    f_tm_bc_cclm = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_cclm_02"+".nc", "r")
  f_tm_bc_wrf  = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_wrf_02"+".nc", "r")
  f_tm_bc_regcm = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_regcm_02"+".nc", "r")
;>>>read error_test 
;########################################################################################
  ; cor_wrf =   f_tm_bc_wrf->$"cor_tm_bc"$
  ; prob_wrf =  f_tm_bc_wrf->$"prob_tm_bc"$ ; corr函数后进行r检验的部分
  minus_wrf      = f_tm_bc_wrf->$"minus_tm_bc"$
  rmse_wrf       = f_tm_bc_wrf->$"rmse"$

  ; cor_cclm =   f_tm_bc_cclm->$"cor_tm_bc"$
  ; prob_cclm =  f_tm_bc_cclm->$"prob_tm_bc"$ ; corr函数后进行r检验的部分
  minus_cclm     = f_tm_bc_cclm->$"minus_tm_bc"$
  rmse_cclm      = f_tm_bc_cclm->$"rmse"$

  ; cor_regcm =   f_tm_bc_regcm->$"cor_tm_bc"$
  ; prob_regcm =  f_tm_bc_regcm->$"prob_tm_bc"$ ; corr函数后进行r检验的部分
  minus_regcm    = f_tm_bc_regcm->$"minus_tm_bc"$
  rmse_regcm     = f_tm_bc_regcm->$"rmse"$

  ; printVarSummary(cor)
  ; printVarSummary(minus)
  ; printVarSummary(prob)
  siglvl = 0.95
;>>>绘图：画空间相关系数/离差
  plot = new(6,graphic) ;定义子图数组
  wks = gsn_open_wks("x11","/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/minus_rmse_bc")
  ; gsn_define_colormap(wks,"MPL_Oranges")
    res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn             = True
  res@cnLinesOn            = False ;填色线条 
  ; res@pmTickMarkDisplayMode = "Always"
  ; res@lbLabelBarOn        = False            ; turn off individual cb's
;-------------------------------------------------------地图区域设置——中国区域res@mp
    res@mpMinLatF=14
    res@mpMaxLatF=55
    res@mpMinLonF=69
    res@mpMaxLonF=140
    res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    res@mpDataSetName="Earth..4"

    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China","Taiwan"/)
    res@mpFillOn=False
    res@gsnAddCyclic=False

    res@mpGridAndLimbOn=True             ;设置经纬线
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10

;-------------------------------------------------------地图标题设置
  ;;;
                
  res@gsnCenterString = "Deviation between BC of WRF & CN05.1 dataset"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;-------------------------------------------------------变量/x/y/刻度设置  
  ; res@cnLineThicknessF     = 0.5
  
  ;;;>>>坐标轴的处理
  res@cnFillPalette         = "MPL_Oranges"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; res@tmXBMode = "automatic" ;指定X轴坐标标签
  ; res@tmYLMode = "Manual" ; 默认"automatic"
  res@tmYLTickStartF = 0  ; 起始最小刻度值
  res@tmYLTickEndF   = 60 ;最大刻度值
  res@tmYLTickSpacingF = 10 ;刻度间隔
  res@tmXBTickSpacingF = 15 

  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 12.
  res@cnLevelSpacingF = 1. ;等值线间隔

;;;;----------------------------------------------------resc 设置
   resc = res
  ; delete(resc@cnLevels)
  resc@gsnCenterString = "RMSE between BC of WRF & CN05.1 dataset"
  resc@cnFillPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  resc@cnLevelSelectionMode  = "ExplicitLevels"  
  ; resc@cnLevels              = (/0.7,0.75,0.8,0.85,0.90,0.92,0.94,0.96,0.98/)  
  ; resc@cnFillColors          = (/2,3,5,6,8,10,11,14,16,17/); -1 为透明
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  resc@cnMinLevelValF = 0.
  resc@cnMaxLevelValF = 8.
  resc@cnLevelSpacingF = 0.5 ;等值线间隔

  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------

  plot(0) = gsn_csm_contour_map(wks, minus_wrf, res)
  plot(3) = gsn_csm_contour_map(wks, rmse_wrf, resc)
;;;;----------------------------------------------CCLM绘制
  res@gsnCenterString = "Deviation between BC of CCLM & CN05.1 dataset"
  resc@gsnCenterString = "RMSE between BC of CCLM & CN05.1 dataset"
  plot(1) = gsn_csm_contour_map(wks, minus_cclm, res)
  plot(4) = gsn_csm_contour_map(wks, rmse_cclm, resc)
  ;;;;----------------------------------------------RegCM绘制
  res@gsnCenterString = "Deviation between BC of RegCM & CN05.1 dataset"
  resc@gsnCenterString = "RMSE between BC of RegCM & CN05.1 dataset"
  plot(2) = gsn_csm_contour_map(wks, minus_regcm, res)
  plot(5) = gsn_csm_contour_map(wks, rmse_regcm, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN TEMPERATURE AT 2M HEIGHT"
  pres@gsnPanelLabelBar      = False ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/2,3/),pres)
;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
  
end