;;;空间相关系数绘图程序
;;;采用前一步输出的空间相关系数场 tm_or_CN051_WRF
;;;叠加了cor的未通过95%置信检验的区域分布prob，用阴影区域绘制；以及平均误差minus
;;;3.14改为了绘制CCLM基本误差
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;>>>read CN05.1&WRF cor data   
  ; f_TM_CN051_WRF = addfile("./practice/bc_data/temporary_data/bc_tm/tm_or_CN051_WRF"+".nc", "r")
  f_TM_CN051_WRF = addfile("./practice/bc_data/temporary_data/bc_tm/tm_or_CN051_CCLM"+".nc", "r")
  ; f_TM_MINUS     = addfile("./practice/bc_data/temporary_data/tm_minus_ave_CN051_WRF"+".nc","r")
  cor =   f_TM_CN051_WRF->$"cor_tm_CCLM_CN051"$
  prob =  f_TM_CN051_WRF->$"prob"$ ; corr函数后进行r检验的部分
  minus = f_TM_CN051_WRF->$"minus_ave_tm_CCLM_CN051"$
  printVarSummary(cor)
  printVarSummary(minus)
  printVarSummary(prob)
  siglvl = 0.95
;>>>绘图：画空间相关系数/离差
  plot = new(2,graphic) ;定义子图数组
  wks = gsn_open_wks("x11","./practice/bc_data/temporary_data/corr-minus")
  gsn_define_colormap(wks,"MPL_Oranges")
  res = True  
  res@gsnDraw   = False 
  res@gsnFrame  = False 
  res@pmTickMarkDisplayMode = "Always"
;-------------------------------------------------------res设置
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
;-------------------------------------------------------------
  ;;;
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用                      
  res@gsnCenterString = "Deviation from the mean field between WRF mode&CN05.1 dataset"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题
  res@pmTickMarkDisplayMode = "Always"
 
  ;;;绘制的地图区域
  ; res@cnMinLevelValF = -40
  ; res@cnMaxLevelValF = 40
  ; res@cnLevelSpacingF = 10 ;等值线间隔
  ; res@mpMinLatF             =  17          ; Asia limits
  ; res@mpMaxLatF             =  55
  ; res@mpMinLonF             =  72
  ; res@mpMaxLonF             = 136
  
  res@cnFillOn             = True
  res@cnLinesOn            = True 
  res@cnLineThicknessF     = 0.5
  
  ;;;>>>坐标轴的处理
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@lbOrientation = "Vertical" ; 把色板垂直地移动
  res@pmTickMarkDisplayMode = "Always"  
  ; res@tmXBMode = "automatic" ;指定X轴坐标标签
  ; res@tmYLMode = "Manual" ; 默认"automatic"
  ; res@tmYLTickStartF = 0  ; 起始最小刻度值
  ; res@tmYLTickEndF   = 60 ;最大刻度值
  res@tmYLTickSpacingF = 10 ;刻度间隔
  res@tmXBTickSpacingF = 15 

;;;;--------------------------------------resc 设置
  resc = res
  resc@gsnContourZeroLineThicknessF = 0. ;略去0线
  resc@cnLevelSelectionMode = "ExplicitLevels" ;
  resc@cnMinLevelValF = 0.9
  resc@cnMaxLevelValF = 1.
  resc@cnLevelSpacingF = 0.1 ;等值线间隔
  resc@gsnCenterString = "Correlation coefficient and 95% significance test between WRF mode&CN05.1 dataset"
  resc@cnFillOn             = False
  
  resc@cnLinesOn            = True 
  resc@cnLineThicknessF     = 3.
  resc@cnLineDashPattern    = 2   
;;;;---------------------------------------------
  plot(0) = gsn_csm_contour_map(wks, minus, res)
  ; gsn_define_colormap(wks,"MPL_Oranges")
  plot(1) = gsn_csm_contour_map(wks, cor, resc)
  opt = True
  opt@gsnShadeFillType = "color" ; 默认设置
  opt@gsnShadeLow = "gray"
  plot(1) = gsn_contour_shade(plot(1), siglvl, -999, opt) ; 从小于等于siglvl的第一个等值线开始用gray填色
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN TEMPERATURE AT 2M HEIGHT"
  ; pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"A","B"/)
  pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/1,2/),pres)
;;;;---------------------------------------------
  draw(plot)
  ; frame(wks)
  
end