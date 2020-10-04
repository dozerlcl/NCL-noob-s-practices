;;;空间相关系数绘图程序
;;;采用前一步输出的空间相关系数场 tm_or_CN051_WRF
;;;叠加了cor的未通过95%置信检验的区域分布prob，用阴影区域绘制；以及平均误差minus
;;;3.14改为了绘制CCLM基本误差
;;;3.16复制为pre的ordata绘图 
;###弃用 在panel中对三个模式的原始误差进行了绘制
; These files are loaded by default in NCL V6.2.0 and newer
begin
;>>>read CN05.1&WRF cor data   
  ; f_TM_CN051_WRF = addfile("./practice/bc_data/temporary_data/bc_tm/tm_or_CN051_WRF"+".nc", "r")
  f_TM_CN051_WRF = addfile("./practice/bc_data/temporary_data/bc_pre/tm_or_CN051_RegCM"+".nc", "r")
  ; f_TM_MINUS     = addfile("./practice/bc_data/temporary_data/tm_minus_ave_CN051_WRF"+".nc","r")
  cor =   f_TM_CN051_WRF->$"cor_tm_WRF_CN051"$      ; 相关系数
  minus_ave_abs = f_TM_CN051_WRF->$"minus_ave_abs"$ ; 绝对误差
  minus_ave_rel = f_TM_CN051_WRF->$"minus_ave_rel"$ ; 相对误差
  ; cv_mod = f_TM_CN051_WRF->$"cv_mod"$
  ; cv_obs = f_TM_CN051_WRF->$"cv_obs"$ 
  siglvl = 0.95
;>>>绘图：画空间相关系数/离差
  plot = new(2,graphic) ;定义子图数组
  wks = gsn_open_wks("x11","./practice/bc_data/temporary_data/pre_ordata_error_03")
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
                
  res@gsnCenterString = "Absolute error between WRF & CN05.1 dataset"
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
  ; gsn_define_colormap(wks,"MPL_Oranges")
  plot(1) = gsn_csm_contour_map(wks, minus_ave_rel, resc)
  ; plot(2) = gsn_csm_contour_map(wks, cv_mod, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN DAILY PRECEPTION"
  ; pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"A","B"/)
  pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/1,2/),pres)

;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
  
end