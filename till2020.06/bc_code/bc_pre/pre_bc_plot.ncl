;;;空间相关系数绘图程序
;;;采用前一步输出的空间相关系数场
;3.16修改为带regcm的部分 3x2
;3.19修改为处理pre的三个模式的类型
;### 仅绘制一个变量 弃用
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;>>>read CN05.1&WRF cor data   
;####################################在文件读取中设置参数##################################
  ; f_tm_bc_cclm = addfile("./practice/bc_data/temporary_data/bc_tm/bc_tm_cclm"+".nc", "r")
  f_tm_bc_wrf  = addfile("./practice/bc_data/temporary_data/bc_pre/bc_tm_regcm"+".nc", "r")
  ; f_tm_bc_regcm = addfile("./practice/bc_data/temporary_data/bc_tm/bc_tm_regcm"+".nc", "r")
;########################################################################################
  cor =   f_tm_bc_wrf->$"cor_tm_bc"$      ; 相关系数
  minus_ave_abs = f_tm_bc_wrf->$"minus_ave_abs"$ ; 绝对误差
  minus_ave_rel = f_tm_bc_wrf->$"minus_ave_rel"$ ; 相对误差


  siglvl = 0.95
;>>>绘图：画空间相关系数/离差
  plot = new(2,graphic) ;定义子图数组
  wks = gsn_open_wks("png","./practice/bc_data/temporary_data/pre_bc_minus_regcm")
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

  ;;;>>>坐标轴的处理
  res@cnFillPalette         = "MPL_Oranges"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  res@tmYLTickStartF = 0  ; 起始最小刻度值
  res@tmYLTickEndF   = 60 ;最大刻度值
  res@tmYLTickSpacingF = 10 ;刻度间隔
  res@tmXBTickSpacingF = 15 

  res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 10
  res@cnLevelSpacingF = 2.0 ;等值线间隔

;;;;----------------------------------------------------resc 设置
   resc = res
  resc@gsnCenterString = "Relative error between WRF & CN05.1 dataset"
  resc@cnFillPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  resc@cnLevelSelectionMode = "ManualLevels"
  ; resc@cnLevelSelectionMode = "AutomaticLevels" 
  resc@cnMinLevelValF = 0
  resc@cnMaxLevelValF = 5
  resc@cnLevelSpacingF = 0.5 ;等值线间隔 
  ; resc@cnLevels              = (/-0.2,-0.1, 0, 0.1, 0.2, 0.3, 0.4/)  
  resc@cnFillColors          = (/-1,-1,9,8,6,4,12,13,14,15,16,17,18,19/); -1 为透明


  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;;---------------------------------------------

  plot(0) = gsn_csm_contour_map(wks, minus_ave_abs, res)
  plot(1) = gsn_csm_contour_map(wks, minus_ave_rel, resc)
;;;;----------------------------------------------CCLM绘制
  ; res@gsnCenterString = "Deviation between BC of CCLM & CN05.1 dataset"
  ; resc@gsnCenterString = "correlation coefficient between BC of CCLM & CN05.1 dataset"
  ; plot(1) = gsn_csm_contour_map(wks, minus_cclm, res)
  ; plot(4) = gsn_csm_contour_map(wks, cor_cclm, resc)
  ;;;;----------------------------------------------RegCM绘制
  ; res@gsnCenterString = "Deviation between BC of RegCM & CN05.1 dataset"
  ; resc@gsnCenterString = "correlation coefficient between BC of RegCM & CN05.1 dataset"
  ; plot(2) = gsn_csm_contour_map(wks, minus_regcm, res)
  ; plot(5) = gsn_csm_contour_map(wks, cor_regcm, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN TEMPERATURE AT 2M HEIGHT"
  pres@gsnPanelLabelBar      = False ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"A","B"/)
  pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/1,2/),pres)
;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
  
end