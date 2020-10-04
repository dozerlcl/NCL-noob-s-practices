;  3.29 绘制BC后的实际情况 平均图 处理 误差订正效果的部分（fact图阴影
;    目标： 绘制平均 + 用点or阴影绘制订正效果较好的位置（用minus衡量）
;    输出 error_test 将BC后误差订正到MOD的1/2的点设为1 其余为0
;    对PRE TM均做了处理,结果在 /bc_tm /bc_pre 下
;#####
; load "./pvs.ncl" ; 根目录下的检查变量的函数
;#####
begin
;>>>---------------------------读取数据
;  >>>读入obs/mod  顺序 mod1,2,3 : WRF CCLM RegCM
;######################################
  ; modname1 = "WRF"
  ; modname2 = "wrf"
    modname1 = "CCLM"
  modname2 = "cclm"
    ; modname1 = "RegCM"
  ; modname2 = "regcm"
;######################################
  f_cat_1 = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_"+modname1+"_step2.nc","r")
  ;>>>>05.1观测数据集,平均气温
    obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    mod1_or = f_cat_1->$"tm_wrf_step2"$
  ; f_cat_2 = addfile("./practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_CCLM_step2.nc","r")
  ;   mod2_or = f_cat_2->$"tm_wrf_step2"$
  ; f_cat_3 = addfile("./practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_RegCM_step2.nc","r")
  ;   mod3_or = f_cat_3->$"tm_wrf_step2"$
;  >>>读入bc
  
  f_bc1 = addfile("~/practice/bc_data/temporary_data/bc_tm/r_to_ncl/bc_tm_"+modname2+".nc", "r")
    bc1_or = f_bc1->$"bc_tm"$
  ; modname = "cclm"
  ; f_bc2 = addfile("./practice/bc_data/temporary_data/bc_pre/r_to_ncl/bc_pre_"+modname+".nc", "r")
  ;   bc2_or = f_bc1->$"bc_tm"$
  ; modname = "regcm"
  ; f_bc3 = addfile("./practice/bc_data/temporary_data/bc_pre/r_to_ncl/bc_pre_"+modname+".nc", "r")
  ;   bc3_or = f_bc1->$"bc_tm"$
;>>>------------------------------------处理数据
;>>>变量 mod[]_or bc[]_or [模式序号]
  error_mod = dim_avg_n(abs(obs_or -  mod1_or),0)
  ; pvs(error_mod)
  error_bc  = dim_avg_n(abs(obs_or -  bc1_or),0)
  error_test_mat1 = error_bc/error_mod ; 用除法衡量
  error_test_mat2 = abs(error_mod - error_bc) ; 用误差的绝对减少量衡量

  error_test = where(error_test_mat1.lt.0.50, 1., 0.)
    ; error_test = where((error_test_mat2.gt.1.), 1., 0.)
  copy_VarMeta(mod1_or(0,:,:), error_test)    
; numerror = sizeof(where(error_bc.lt.error_mod, 1, 0))
  ; pvs(error_test)
;>>>-----------------------------------将误差降至原先一般一下的区域用点打出
path_out = "~/practice/bc_data/temporary_data/bc_tm/bc_tm_error_test_"+modname2+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
  ncdf->error_test = error_test
  delete(ncdf)
;>>>-----------------------------------绘图检查数据
wks = gsn_open_wks("x11","~/practice/bc_data/temporary_data/pre_errortest")
sres                 = True                                                           ; set up a second resource list               
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
   sres@cnFillDotSizeF       = 0.0025
;>>>地图区域设置
    sres@mpMinLatF=14
    sres@mpMaxLatF=55
    sres@mpMinLonF=69
    sres@mpMaxLonF=140
    sres@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    sres@mpDataSetName="Earth..4"

    sres@mpOutlineOn=True
    sres@mpOutlineSpecifiers=(/"China","Taiwan"/)
    sres@mpFillOn=False
    sres@gsnAddCyclic=False

    sres@mpGridAndLimbOn=True             ;设置经纬线
    sres@mpGridLineThicknessF=0.5
    sres@mpGridLineDashPattern=0.5
    sres@mpGridLineDashPattern=2
    sres@mpGridSpacingF=10

;>>>plot
   plot                = gsn_csm_contour_map(wks,error_test,sres)
   draw(plot)
   frame(wks)
end