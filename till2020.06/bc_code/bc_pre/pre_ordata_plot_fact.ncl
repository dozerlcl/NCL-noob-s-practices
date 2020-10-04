;CN0.1_Tm_198901_200912_daily_025x025 和 WRF_TMEAN_daily_025x025 两个文件的读取处理脚本
;将空间系数cor和置信区间prob和平均误差minus_ave 保存到 tm_or_CN051_WRF 文件中
;3.13 将mod文件从wrf改为cclm
;注意变量名wrf指模式，CN051指观测
;3.16 +处理 RegCM_TMEAN_daily_025x025
;3.17 拷贝副本修改为处理pre的形式
;3.18 +针对日降水的变异系数计算(注意处理年纪变率，可能修改分段)
;     +降水minus修改为相对误差
;     +降水wet.day
;3.19 +修改为处理CCLM的PRE数据 CCLM_PRE_daily_025x025
;3.21 +-修改为进行模式PRE原始数据输出整理的脚本
;3.29 + BC 以及 订正效果好的点
begin
;>>>read data from pre_ordata_read_cat.ncl output   
  ;>>>read data from pre_ordata_read_cat.ncl output   
  f_cat_1 = addfile("~/practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_WRF_step2.nc","r")
  ; ;>>>>05.1观测数据集,平均气温
    pre_obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    pre_mod1_or = f_cat_1->$"tm_wrf_step2"$
  f_cat_2 = addfile("~/practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_CCLM_step2.nc","r")
    pre_mod2_or = f_cat_2->$"tm_wrf_step2"$
  f_cat_3 = addfile("~/practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_RegCM_step2.nc","r")
    pre_mod3_or = f_cat_3->$"tm_wrf_step2"$
;>>>read data from BC result
  bcname = (/"wrf","cclm","regcm"/)
  path_bc = "~/practice/bc_data/temporary_data/bc_pre/r_to_ncl/bc_pre_"+bcname+".nc"
  f_bc_1 = addfile(path_bc(0), "r")
    pre_mod1_bc = f_bc_1->$"bc_tm"$
  f_cat_2 = addfile(path_bc(1),"r")
    pre_mod2_bc = f_cat_2->$"bc_tm"$
  f_cat_3 = addfile(path_bc(2),"r")
    pre_mod3_bc = f_cat_3->$"bc_tm"$
;>>>读入检查误差修正情况的0/1图（1为修正超过一半，理解为订正显著的部分）
  modname = "wrf"
  path_error = "~/practice/bc_data/temporary_data/bc_pre/bc_tm_error_test_"+modname+".nc"
  f_error_1 = addfile(path_error, "r")
  mod1_error = f_error_1->$"error_test"$
  modname = "cclm"
  path_error = "~/practice/bc_data/temporary_data/bc_pre/bc_tm_error_test_"+modname+".nc"
  f_error_2 = addfile(path_error, "r")
  mod2_error = f_error_2->$"error_test"$
  modname = "regcm"
  path_error = "~/practice/bc_data/temporary_data/bc_pre/bc_tm_error_test_"+modname+".nc"
  f_error_3 = addfile(path_error, "r")
  mod3_error = f_error_3->$"error_test"$
  ;>>>检查数据 CN051 unit: C wrf_cat unit K
  ;>>>降水检查数据的时候将wet.day阈值设置为0.01mm
    ; pre_mod1_or = where(pre_mod1_or.lt.0.01, 0, pre_mod1_or)

  ;---------------------------------------------------------缺失值/wet.day检测(用where进行检测)
  ; obs_tm_good = where(.not.ismissing(tm_CN051_cat), 1, 0)
  ; obs_tm_good_sum = dim_sum_n(obs_tm_good, 0)
  ; printVarSummary(obs_tm_good_sum)
  ; write_matrix(obs_tm_good_sum, "15I7", False)
  pre_mod1_bc = where(pre_mod1_bc.lt.0.001, 0, pre_mod1_bc)
  pre_mod2_bc = where(pre_mod2_bc.lt.0.001, 0, pre_mod2_bc)
  pre_mod3_bc = where(pre_mod3_bc.lt.0.001, 0, pre_mod3_bc)

  pre_mod1_or = where(pre_mod1_or.lt.0.001, 0, pre_mod1_or)
  pre_mod2_or = where(pre_mod2_or.lt.0.001, 0, pre_mod2_or)
  pre_mod3_or = where(pre_mod3_or.lt.0.001, 0, pre_mod3_or)
  ;-------------------------------------------------OBS中的缺失值都是 完全缺失；时间序列不缺失就是整齐的
;>>>计算平均值 1-WRF 2-CCLM 3-RegCM
  total_obs = dim_avg_n(pre_obs_or, 0)
  total_mod_1 = dim_avg_n(pre_mod1_or, 0)
  total_mod_2 = dim_avg_n(pre_mod2_or, 0)
  total_mod_3 = dim_avg_n(pre_mod3_or, 0)

  total_bc_1 = dim_avg_n(pre_mod1_bc, 0)
  total_bc_2 = dim_avg_n(pre_mod2_bc, 0)
  total_bc_3 = dim_avg_n(pre_mod3_bc, 0)
  ; 如果不拷贝meta信息会出错？
  ; 复制缺失值位置信息/做mask
  total_mod_1 = where(ismissing(total_obs), total_mod_1@_FillValue, total_mod_1)
  total_mod_2 = where(ismissing(total_obs), total_mod_2@_FillValue, total_mod_2)
  total_mod_3 = where(ismissing(total_obs), total_mod_3@_FillValue, total_mod_3)

  total_bc_1 = where(ismissing(total_obs), total_bc_1@_FillValue, total_bc_1)
  total_bc_2 = where(ismissing(total_obs), total_bc_2@_FillValue, total_bc_2)
  total_bc_3 = where(ismissing(total_obs), total_bc_3@_FillValue, total_bc_3)
  copy_VarMeta(pre_obs_or(0,:,:), total_obs)
  copy_VarMeta(pre_obs_or(0,:,:), total_mod_1)
  copy_VarMeta(pre_obs_or(0,:,:), total_mod_2)
  copy_VarMeta(pre_obs_or(0,:,:), total_mod_3)

  copy_VarMeta(pre_obs_or(0,:,:), total_bc_1)
  copy_VarMeta(pre_obs_or(0,:,:), total_bc_2)
  copy_VarMeta(pre_obs_or(0,:,:), total_bc_3)
  ; printVarSummary(total_obs)
  ; printVarSummary(total_mod_1)
  ; printMinMax(total_obs, 1)
  ; printMinMax(total_mod_1, 1) 
; ;>>>预存作图数据 作图变量 cor_tm(WRF&cn05.1)

; ;>>>绘图：画平均值分布图
plot = new(7,graphic) ;定义子图数组
  wks = gsn_open_wks("png","~/practice/bc_data/temporary_data/fact_pre_bc_panel")
  ; gsn_define_colormap(wks,"MPL_Oranges")
  res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnLabelDrawOrder    = "PreDraw"        ; 先绘制等高线，之后会被覆盖
  res@cnFillOn             = True
  res@cnLinesOn            = False ;填色线条 
  ; res@pmTickMarkDisplayMode = "Always"
  res@lbLabelBarOn        = False            ; turn off individual cb's
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
                
  res@gsnCenterString = "CN05.1"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号(未起作用)
  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题

;-------------------------------------------------------变量/x/y/刻度设置  

  ;;;>>>坐标轴的处理
  res@cnFillPalette         = "precip_11lev"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; res@tmYLTickStartF = 0  ; 起始最小刻度值
  ; res@tmYLTickEndF   = 60 ;最大刻度值
  ; res@tmYLTickSpacingF = 10 ;刻度间隔
  ; res@tmXBTickSpacingF = 15 

  ; res@lbOrientation = "Vertical" ; 把色板垂直地移动 
  ; res@gsnContourZeroLineThicknessF = 0. ;略去0线
 
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  ; res@cnLevelSelectionMode  = "ExplicitLevels"
  ; res@cnLevels = ispan(0, 20, 2)
  ; res@cnFillColors = ispan(0, 176, 16)
  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 10
  res@cnLevelSpacingF = 1 ;等值线间隔

;;;;----------------------------------------------------resc 设置
   resc = res
  resc@gsnCenterString = ""
  ; resc@cnFillPalette         = "GMT_polar"; 用GMT_gray 进行填色。即调用了第2种色板(调色板设置)
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  resc@cnLevelSelectionMode = "ManualLevels"
  ; resc@cnLevelSelectionMode = "AutomaticLevels" 
  ; resc@cnMinLevelValF = 0
  ; resc@cnMaxLevelValF = 11
  ; resc@cnLevelSpacingF = 1 ;等值线间隔 
  ; resc@cnLevels              = (/-0.2,-0.1, 0, 0.1, 0.2, 0.3, 0.4/)  
  ; resc@cnFillColors          = (/-1,-1,9,8,6,4,12,13,14,15,16,17,18,19/); -1 为透明


  ; resc@cnInfoLabelOn         = True       ; 关闭图右下 方的等值线信息标签
  ; resc@lbLabelBarOn          = True       ; 关闭labelbar
;;;-----------------------------------------------------sres 设置（订正效果点
sres                 = resc                                                           ; set up a second resource list               
   sres@gsnDraw         = False                                                          ;         do not draw the plot               
   sres@gsnFrame        = False                                                          ; do not advance the frame                    
   sres@cnLineLabelsOn  = False                                                          ; do not use line labels                     
   sres@cnLinesOn       = False                                                          ; do not draw contour lines                  
   sres@cnInfoLabelOn   = False                                                                                                        
   sres@cnFillOn        = True                                                  ; color fill                                   
   sres@cnSmoothingOn   = True
   sres@lbLabelBarOn= False                                                                                                            
   sres@cnLevelSelectionMode = "ExplicitLevels"                                                                                             
   sres@cnFillDrawOrder="postDraw"                                                                                                     
   sres@cnLevels    = (/0.9999/)                                                                                                
   sres@cnMonoFillPattern    = False            ; want multiple patterns                                                               
   sres@cnFillPatterns       = (/-1,17/)     ; the patterns                                                                        
   sres@cnMonoFillScale      = False            ; want different densities                                                            
   sres@cnFillScales         = (/1,1/)    ; change densities                                                                        
   sres@cnMonoFillColor      =True                                                                                                     
   sres@cnFillDotSizeF       = 0.0050
  ;;;;---------------------------------------------
  plot(0) = gsn_csm_contour_map(wks, total_obs, res)
  ; gsn_define_colormap(wks,"MPL_Oranges")
  resc@gsnCenterString = "WRF"
  plot(1) = gsn_csm_contour_map(wks, total_mod_1, resc)
  plot(4) = gsn_csm_contour_map(wks, total_bc_1, resc)
  shade1   = gsn_csm_contour(wks,mod1_error,sres)
  overlay(plot(4),shade1)   
  resc@gsnCenterString = "CCLM"
  plot(2) = gsn_csm_contour_map(wks, total_mod_2, resc)
  plot(5) = gsn_csm_contour_map(wks, total_bc_2, resc)
  shade2   = gsn_csm_contour(wks,mod2_error,sres)
  overlay(plot(5),shade2)   
  resc@gsnCenterString = "RegCM"
  plot(3) = gsn_csm_contour_map(wks, total_mod_3, resc)
  plot(6) = gsn_csm_contour_map(wks, total_bc_3, resc)
  shade3   = gsn_csm_contour(wks,mod3_error,sres)
  overlay(plot(6),shade3)   
  ; plot(2) = gsn_csm_contour_map(wks, cv_mod, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN DAILY PRECEPTION DURING 2000-2001"
  pres@gsnPanelRowSpec = True                   ; tell panel what order to plot
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"a","b","c","d","e","f","g"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/1,3,3/),pres)

;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
end
              