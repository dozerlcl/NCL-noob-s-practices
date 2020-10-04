;;; 4.19 由 tm_ordata_plot_panel 改
;;;    将同一个量的BC和MOD放在一张图上
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;>>>read CN05.1&WRF cor data  / CCLM cor data
  f_TM_CN051_WRF = addfile("~/practice/bc_data/temporary_data/bc_tm/tm_or_CN051_WRF_02"+".nc", "r")
  f_TM_CN051_CCLM = addfile("~/practice/bc_data/temporary_data/bc_tm/tm_or_CN051_CCLM_02"+".nc", "r")
  f_TM_CN051_RegCM = addfile("~/practice/bc_data/temporary_data/bc_tm/tm_or_CN051_RegCM_02"+".nc", "r")

  f_tm_bc_cclm = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_cclm_02"+".nc", "r")
  f_tm_bc_wrf  = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_wrf_02"+".nc", "r")
  f_tm_bc_regcm = addfile("/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_tm/bc_tm_regcm_02"+".nc", "r")
  ; cor_wrf =   f_TM_CN051_WRF->$"cor_tm_WRF_CN051"$
  ; prob_wrf =  f_TM_CN051_WRF->$"prob"$ ; corr函数后进行r检验的部分
;   minus_wrf         = f_TM_CN051_WRF->$"minus_ave_tm_WRF_CN051"$
;   minus_wrf_bc      = f_tm_bc_wrf->$"minus_tm_bc"$
;   minus_wrf         = f_TM_CN051_WRF->$"minus_ave_tm_WRF_CN051"$
;   minus_wrf_bc      = f_tm_bc_wrf->$"minus_tm_bc"$

  minus_wrf         = f_TM_CN051_WRF->$"rmse"$
  minus_wrf_bc      = f_tm_bc_wrf->$"rmse"$

;   minus_cclm        = f_TM_CN051_CCLM->$"minus_ave_tm_WRF_CN051"$
;   minus_cclm_bc     = f_tm_bc_cclm->$"minus_tm_bc"$

  minus_cclm        = f_TM_CN051_CCLM->$"rmse"$
  minus_cclm_bc     = f_tm_bc_cclm->$"rmse"$

;   minus_regcm = f_TM_CN051_RegCM->$"minus_ave_tm_WRF_CN051"$
;   minus_regcm_bc    = f_tm_bc_regcm->$"minus_tm_bc"$

  minus_regcm = f_TM_CN051_RegCM->$"rmse"$
  minus_regcm_bc    = f_tm_bc_regcm->$"rmse"$

  ;#################################;第一次，之后###用在脚本内调整参数的地方###################
  siglvl = 0.95; 设置置信区间 弃用
  ;#########################################################################################
;>>>检查数据
  ; printVarSummary(cor_cclm)
  ; printMinMax(cor_cclm,-1)
  ; printVarSummary(cor_wrf)
  ; printMinMax(cor_wrf,-1)
;>>>绘图：画空间相关系数/离差
  plot = new(6,graphic) ;定义子图数组
  wks = gsn_open_wks("png","~/practice/bc_data/temporary_data/tm_rmse")
  ; gsn_define_colormap(wks,"MPL_Oranges+GMT_polar") ;在后续定义，不用
  res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnLineLabelsOn      = False
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
                
  res@gsnCenterString = "Deviation of WRF"
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
  res@lbLabelBarOn  = False
;   res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 12.
  res@cnLevelSpacingF = 1. ;等值线间隔

;;;;----------------------------------------------------resc 设置
   resc = res
  resc@gsnCenterString = "RMSE of WRF"
  resc@cnFillPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnMaxLevelCount      = 10
  ; resc@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels
  ; resc@cnLevels              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14/)  
  ; resc@cnFillColors          = (/1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18/); -1 为透明
  resc@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  resc@cnMinLevelValF = 0.
  resc@cnMaxLevelValF = 8.
  resc@cnLevelSpacingF = 0.5 ;等值线间隔
  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------WRF绘制
  plot(0) = gsn_csm_contour_map(wks, minus_wrf, resc)
  resc@gsnCenterString = "RMSE of WRF Bias Correction"
  plot(3) = gsn_csm_contour_map(wks, minus_wrf_bc, resc)
;;;;----------------------------------------------CCLM绘制
;   res@gsnCenterString = "RMSE between CCLM & CN05.1 dataset"
;   resc@gsnCenterString = "RMSE between CCLM & CN05.1 dataset"
  resc@gsnCenterString = "RMSE of CCLM"
  plot(1) = gsn_csm_contour_map(wks, minus_cclm, resc)
  resc@gsnCenterString = "RMSE of CCLM Bias Correction"
  plot(4) = gsn_csm_contour_map(wks, minus_cclm_bc, resc)
  ;;;;----------------------------------------------RegCM绘制
;   res@gsnCenterString = "RMSE between RegCM & CN05.1 dataset"
;   resc@gsnCenterString = "RMSE between RegCM & CN05.1 dataset"
  resc@gsnCenterString = "RMSE of RegCM"
  plot(2) = gsn_csm_contour_map(wks, minus_regcm, resc)
  resc@gsnCenterString = "RMSE of RegCM Bias Correction"
  plot(5) = gsn_csm_contour_map(wks, minus_regcm_bc, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN TEMPERATURE AT 2M HEIGHT"
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/2,3/),pres)
;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
end