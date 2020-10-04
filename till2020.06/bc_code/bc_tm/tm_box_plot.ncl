; 3.30 箱线图绘制 quantile-box
;      调整于示例脚本 box_8.ncl 
;      data: OBS/MOD/BC 平均图 （使用散点的分布会导致内存溢出
;      未绘制散点位置，数量过多
;      做各个季节的平均结果/用列表将各个季节ind值进行传递

;*************************************************
 ; example program for Box-Percentile-Plots
 ;
 ; based on: Esty WW, Banfield J: The box-percentile plot. J Statistical Software 8 No. 17, 2003.
 ;
 ;************************************************
;
;  These files are loaded by default in NCL V6.2.0 and newer
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
;  These files still have to be loaded manually
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/box_percentile_plot.ncl"
;  load "./pvs.ncl"
 ; load "./box_percentile_plot.ncl"
 ;************************************************
 begin ; program
 ;>>>-------------------整理数据，将BC/MOD ndtooned(val) 以行的方式排列进data中

    f_cat_1 = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_WRF_step2.nc","r")
  ; ;>>>>05.1观测数据集,平均气温
    obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    mod1_or = f_cat_1->$"tm_wrf_step2"$
  f_cat_2 = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_CCLM_step2.nc","r")
    mod2_or = f_cat_2->$"tm_wrf_step2"$
  f_cat_3 = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_RegCM_step2.nc","r")
    mod3_or = f_cat_3->$"tm_wrf_step2"$
;>>>read data from BC result
  bcname = (/"wrf","cclm","regcm"/)
  path_bc = "~/practice/bc_data/temporary_data/bc_tm/r_to_ncl/bc_tm_"+bcname+".nc"
  f_bc_1 = addfile(path_bc(0), "r")
    mod1_bc = f_bc_1->$"bc_tm"$
  f_cat_2 = addfile(path_bc(1),"r")
    mod2_bc = f_cat_2->$"bc_tm"$
  f_cat_3 = addfile(path_bc(2),"r")
    mod3_bc = f_cat_3->$"bc_tm"$

  ;>>>检查数据 CN051 unit: C wrf_cat unit K
      ; pre_mod3_or = pre_mod3_or - 273.15
  ;>>>降水检查数据的时候将wet.day阈值设置为0.01mm
    ; pre_mod1_or = where(pre_mod1_or.lt.0.01, 0, pre_mod1_or)
  ;---------------------------------------------------------缺失值检测(用where进行检测)
  ; obs_tm_good = where(.not.ismissing(tm_CN051_cat), 1, 0)
  ; obs_tm_good_sum = dim_sum_n(obs_tm_good, 0)
  ; printVarSummary(obs_tm_good_sum)
  ; write_matrix(obs_tm_good_sum, "15I7", False)
  ;>>>-------------------------------------------------拆分年份
  time_or = cd_calendar(obs_or&time, 0) ; time_or为730 x 6 6个时间分别是yy mm dd hh mm ss
  ; 下面提取DJF
  ind_DJF = ind(time_or(:,1).eq.1.or.time_or(:,1).eq.2.or.time_or(:,1).eq.12)
  ind_MAM = ind(time_or(:,1).eq.3.or.time_or(:,1).eq.4.or.time_or(:,1).eq.5)
  ind_JJA = ind(time_or(:,1).eq.6.or.time_or(:,1).eq.7.or.time_or(:,1).eq.8)
  ind_SON = ind(time_or(:,1).eq.9.or.time_or(:,1).eq.10.or.time_or(:,1).eq.11)
  ind_list = NewList("fifo")
  ListAppend(ind_list, ind_DJF)
  ListAppend(ind_list, ind_MAM)
  ListAppend(ind_list, ind_JJA)
  ListAppend(ind_list, ind_SON)
  ; printVarSummary(ind_list[1])
  ;-------------------------------------------------OBS中的缺失值都是 完全缺失；时间序列不缺失就是整齐的
;>>>ndtooned(val) val: obs_or mod[]_or mod[]_bc
;###################
season = "ANNUAL"
yminf  = -35
ymaxf  = 40
wtype  = "png"
; wtype  = "x11"
seasoni = 3 ; 0-DJF 1-MAM 2-JJA 3-SON
;####################
;计算 seasoni对应季节
  ; obs_or_one = ndtooned(dim_avg_n(obs_or(ind_list[seasoni],:,:), 0))

  ; mod1_or_one = ndtooned(dim_avg_n(mod1_or(ind_list[seasoni],:,:), 0))
  ; mod2_or_one = ndtooned(dim_avg_n(mod2_or(ind_list[seasoni],:,:), 0))
  ; mod3_or_one = ndtooned(dim_avg_n(mod3_or(ind_list[seasoni],:,:), 0))

  ; mod1_bc_one = ndtooned(dim_avg_n(mod1_bc(ind_list[seasoni],:,:), 0))
  ; mod2_bc_one = ndtooned(dim_avg_n(mod2_bc(ind_list[seasoni],:,:), 0))
  ; mod3_bc_one = ndtooned(dim_avg_n(mod3_bc(ind_list[seasoni],:,:), 0))

  obs_or_one = ndtooned(dim_avg_n(obs_or(:,:,:), 0))

  mod1_or_one = ndtooned(dim_avg_n(mod1_or(:,:,:), 0))
  mod2_or_one = ndtooned(dim_avg_n(mod2_or(:,:,:), 0))
  mod3_or_one = ndtooned(dim_avg_n(mod3_or(:,:,:), 0))

  mod1_bc_one = ndtooned(dim_avg_n(mod1_bc(:,:,:), 0))
  mod2_bc_one = ndtooned(dim_avg_n(mod2_bc(:,:,:), 0))
  mod3_bc_one = ndtooned(dim_avg_n(mod3_bc(:,:,:), 0))

  obs_good = ind(.not.ismissing(obs_or_one))
  obs  = obs_or_one(obs_good)

  mod1 = mod1_or_one(obs_good)
  mod2 = mod2_or_one(obs_good)  
  mod3 = mod3_or_one(obs_good) 

  bc1 = mod1_bc_one(obs_good)
  bc2 = mod2_bc_one(obs_good)  
  bc3 = mod3_bc_one(obs_good)
  ; printVarSummary(obs)
  ; print(obs(0:99))
  dims_obs = dimsizes(obs)
  data = new((/4,9,dims_obs/), float)
  ; data@_FillValue = obs@_FillValue
  data(0,0,:) =  obs;(0:100 - 1)
  data(0,2,:) = mod1;(0:100 - 1)
  data(0,3,:) = mod2;(0:100 - 1)
  data(0,4,:) = mod3;(0:100 - 1)

  data(0,6,:) =  bc1;(0:100 - 1)
  data(0,7,:) =  bc2;(0:100 - 1)
  data(0,8,:) =  bc3;(0:100 - 1)
  ; printVarSummary(data)

 ;>>>-----------------------------------------------------------------------
 ;************************************************
 ;************************************************
 ; create plot
  wtype@wkWidth                  =   1200              ; Set the pixel size of image.
  wtype@wkHeight                 =   1000              ; Set the pixel size of image.
  wks                            = gsn_open_wks(wtype,"~/practice/bc_data/temporary_data/box_tm_"+season)
  res                          = True
  ; res@tmXBLabels               = (/"RCP2.6","RCP4.5","RCP8.5","","RCP2.6","RCP4.5","RCP8.5","","RCP2.6","RCP4.5","RCP8.5"/)
  res@tmXBLabels               = (/"OBS"," ","WRF","CCLM","RegCM"," ","WRF_BC","CCLM_BC","RegCM_BC"/)
  res@tmXBLabelFontHeightF     = 0.02 
  res@tmXBLabelAngleF          = 45
  res@tmXBLabelJust            = "CenterCenter"
  res@tmYMajorGrid                = True          ; implement y grid
  res@tmYMajorGridLineDashPattern = 1             ; select short dash lines
  res@trYMinF                  = yminf ;-90
  res@trYMaxF                  = ymaxf ; 90
  res@tiMainFontHeightF        = 0.023
  res@tiMainString             = "DAILY PRE-"+season
  res@tmXTBorderOn             = True
  res@tmYRBorderOn             = True 
  res@tmYUseLeft              = True
  res@vpXF                     = 0.15
  res@vpYF                     = 0.9
  res@vpWidthF                 = 0.85
  res@vpHeightF                = 0.65 
  res@tiYAxisString            =   ""
  ; res@tiXAxisString            =   "2021-2050        2041-2070       2071-2100"
  res@tiXAxisFontHeightF      = 0.03
  boxOpts                      = True
  boxOpts@boxWidth             = 0.3  ; with DNA == True 0.3 / without 0.4
  lineRes                      = True
  lineRes@gsLineThicknessF     = 0.9
  lineRes@txFontHeightF            = 5  
  lineRes@tmXBLabelFontHeightF     = 9
  markerRes                    = True 
  markerRes@gsMarkerIndex      = 1
  markerRes@gsMarkerSizeF      = 0.05
  markerRes@gsMarkerThicknessF = 1
  markerRes@gsMarkerColor      = "black"; (/"red","blue"/) ;"blue"
  PerRes                       = True
  PerRes@gsLineColor           = "black"; (/"blue","red"/) ;"blue"
  PerRes@gsLineThicknessF      = 5  
  ; fillcolor 不做调整
  PerRes@gsFillColor           = (/"(/0.74, 0.84, 0.91/)",\
                                  "(/1.00, 1.00, 1.00/)", \ ; grau
                                  "(/0.99, 0.68, 0.57/)","(/0.87, 0.18, 0.15/)","(/0.65, 0.06, 0.08/)",\ ; red
                                  "(/1.00, 1.00, 1.00/)", \ ; grau
                                  "(/0.19, 0.51, 0.74/)","(/0.03, 0.32, 0.61/)","(/0.10, 0.30, 0.90/)"/) ; blau
                                    
                                  
  PerRes@FillBox               = True ;(/True,False/)
  PerRes@MarkPer               = True ;(/True,False/)
  PerRes@Avg                   = True ;(/True,False/)
  ; DNA                          = False ;True 关闭DNA（散点的具体位置
  DNA                          = False ;True 关闭DNA（散点的具体位置
  ; DNA@gsLineColor           = (/ "green","green","green","green","green","green","green","green","green","green","green","green","green","green","black","black","black","black","black","black","black","black","black","black","black","black","black","green"/)
  DNA@gsLineThicknessF     = 6.0
  NoMember                     = False ; False ;True ； 多少个点参与
  NoMember@txFontHeightF       = 0.015 
  NoMember@txJust              = "BottomLeft"
  ; data示例 各行为一个箱线图示例
  ; data                           = new((/11,028/),float)
  ; data@_FillValue                = -999.
  ; data(0,:)                      = (/  -999.0, -999.0, -999.0,    0.9, -999.0,    1.4,    1.6,    1.1,    0.9, -999.0, -999.0, -999.0,    0.9,    0.8, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.1, -999.0, -999.0, -999.0, -999.0, -999.0/)
  ; data(1,:)                      = (/     1.6,    0.9,    1.5,    1.2,    1.3,    1.4,    1.6,    1.0, -999.0, -999.0,    1.3,    0.7, -999.0, -999.0,    0.7,    1.1,    2.0,    0.7,    1.2,    1.2,    1.4,    0.9,    1.3,    1.7,    1.4,    1.0,    1.3, -999.0/)
  ; data(2,:)                      = (/     1.6,    0.9,    1.8,    1.5,    1.3,    1.6,    1.9,    0.9, -999.0, -999.0,    1.1,    0.8, -999.0, -999.0,    0.8,    1.3,    2.2,    0.8,    1.4,    1.4,    1.4,    1.0,    1.6,    1.9,    1.4,    1.0,    1.0,    1.8/)
  ; data(3,:)                      = (/  -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0/)
  ; data(4,:)                      = (/  -999.0, -999.0, -999.0,    1.2, -999.0,    1.6,    1.5,    1.1,    1.1, -999.0, -999.0, -999.0,    1.0,    1.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.3, -999.0, -999.0, -999.0, -999.0, -999.0/)
  ; data(5,:)                      = (/     2.0,    1.4,    2.4,    1.7,    1.8,    1.6,    2.3,    1.1, -999.0, -999.0,    1.7,    0.9, -999.0, -999.0,    1.3,    1.7,    2.9,    0.9,    1.8,    1.6,    1.3,    1.4,    1.9,    2.3,    1.8,    1.2,    1.7, -999.0/)
  ; data(6,:)                      = (/     2.6,    1.8,    2.9,    2.4,    2.6,    2.4,    2.8,    1.8, -999.0, -999.0,    2.1,    1.7, -999.0, -999.0,    1.6,    2.1,    3.2,    1.6,    2.2,    2.0,    1.9,    1.9,    2.5,    2.8,    2.7,    2.0,    2.0,    2.8/)
  ; data(7,:)                      = (/  -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0/)
  ; data(8,:)                      = (/  -999.0, -999.0, -999.0,    1.1, -999.0,    1.2,    1.6,    1.0,    1.0, -999.0, -999.0, -999.0,    1.0,    0.9, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.2, -999.0, -999.0, -999.0, -999.0, -999.0/)
  ; data(9,:)                      = (/     2.5,    1.8,    2.3,    2.1,    2.4,    2.0,    2.8,    1.7, -999.0, -999.0,    2.2,    1.5, -999.0, -999.0,    1.8,    2.0,    3.2,    1.4,    2.3,    1.8,    2.1,    1.9,    2.3,    2.8,    2.5,    1.8,    2.1, -999.0/)
  ; data(10,:)                      = (/     4.7,    3.3,    4.7,    3.8,    4.2,    4.3,    4.7,    3.4, -999.0, -999.0,    3.6,    2.9, -999.0, -999.0,    3.1,    3.6,    5.4,    3.0,    4.0,    3.4,    3.7,    3.5,    4.1,    4.8,    4.2,    3.5,    3.5,    4.6/)
  box = new(4,graphic)
  box(0)   = box_percentile_plot( wks,data(0,:,:), res,boxOpts,lineRes,PerRes,markerRes,DNA,NoMember)
  txres = True
  gsres = True
  txres@txFontHeightF = 0.015 
  txres@txJust = "CenterCenter"
  Auml    = "A~H-15V6F35~H~FV-6H3~"
  ;gsn_text_ndc(wks,Auml+"nderung zu ",0.1,0.170,txres)
  txres@txJust = "CenterCenter"
  txres@txFontHeightF = 0.025 
  gsn_text_ndc(wks,"[~S~o~N~C]",0.1,0.200,txres)  ; 气温资料单位 
  ; gsn_text_ndc(wks,"mm",0.1,0.200,txres) ; 降水资料单位
 ;************************************************
 ; Drawing plot
 ; pannel setting

   draw(box(0))
   frame(wks)
 ;************************************************
 end ; program
;************************************************   

