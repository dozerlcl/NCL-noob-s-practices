begin
  ;各层纬向平均气温场 和 PC1的相关系数
  itimes = 197901 ;起始年月 
  itimee = 201001 ;结束年月
  
  siglvl = 0.05   ; 置信度 , 之后counter填色有使用

;>>>read air data   
  f   = addfile("./practice/lx2_data/air.mon.mean.nc", "r")
  var    := short2flt(f->air)
  time   := f->time
  YYYYMM := cd_calendar(time,-1)
  ist = ind(itimes.eq.YYYYMM)
  ied = ind(itimee.eq.YYYYMM)  
  
  air = var(ist:ied:12, :, :, :) ; 逐年一月份数据 time x level x lon x lat
  delete(var)
  air_zm = dim_avg_Wrap(air) ; 对数组最右边维平均，保留meta data。这里即是纬向平均
  dims   = dimsizes(air_zm)
  
;>>>read AOI data   
  ncfile = addfile("./practice/lx5_data/temporary_data/SLP-PC1-jan34yr.nc","r")
  eof_ts = ncfile->AOI
  eof_ts&Time = cd_calendar(eof_ts&Time, 4)
  ; printVarSummary(eof_ts)
  AOI = eof_ts({Time|1979:2010}) ; 截取部分时间段，以保证与air数据一致
;;相关并检验
  mxlag = 0   ; 同时相关
  corr = esccr(AOI, air_zm(level|:, lat|:, time|:), mxlag)   ;输出场为[17] x [73] x [1]
  ; printVarSummary(corr)
  var := (/corr(:,:,0)/)  ; 只保留数据的复制, 简化成二维
  ; printVarSummary(var)
  copy_VarMeta(air_zm(0,:,:),var) ; 拷贝元数据 将第一个维度（level）固定之后就只拷贝后两维
  ; printVarSummary(var)
  prob = rtest(var, dims(0), 0)
  copy_VarMeta(air_zm(0,:,:), prob)
  ; printVarSummary(prob)
;>>>**plot**************************************
  wks   = gsn_open_wks ("x11", "plot-corr-AO")    
  gsn_define_colormap(wks,"BlWhRe")               
  
  res                = True                 
  res@gsnDraw        = False   
  res@gsnFrame       = False   
  res@gsnLeftString  = ""
  res@gsnRightString = ""

  res@tmXBMode                = "Explicit"
  res@tmXBValues              = (/-90,-60,-30,0,30,60,90/)         ;若是在地图上绘制，则这些数值指定其纬度
  res@tmXBLabels              = (/"90~S~o~N~S","60~S~o~N~S",\
                                 "30~S~o~N~S","0","30~S~o~N~N","60~S~o~N~N","90~S~o~N~N"/)\
                                 ;在对应位置上添加带圈号的纬度。这里使用了默认的function code ~。
  res@tmXBLabelDeltaF         = -0.6                    ; 移动其位置，使其更加靠近X轴
  res@tmXBLabelFontHeightF    = 0.015                    ; 字体大小
  res@tmYLLabelFontHeightF    = 0.015                    ; 字体大小
  
  res@tiYAxisString   = "Level (hPa)"
    
  res@cnFillOn             = True                  ; turn on color
  res@cnLinesOn            = False                 ; no contour lines
  res@cnLineLabelsOn       = False
        
  res@gsnContourZeroLineThicknessF  = 0.
  res@cnInfoLabelOn        = False
  res@cnLevelSpacingF      = 0.05
  res@lbLabelBarOn         = False
      
  base = gsn_csm_pres_hgt(wks,prob,res)
  
  opt = True
  opt@gsnShadeFillType = "color" ; 默认设置
  opt@gsnShadeLow = "gray"
  base = gsn_contour_shade(base, siglvl, -999, opt) ; 从小于等于siglvl的第一个等值线开始用gray填色


  res@cnFillOn             = False    
  res@cnLinesOn            = True     
  res@cnLevelSpacingF      = 0.15
  res@cnLineDashPattern    = 2
  res@cnLineThicknessF     = 3.
  res@cnInfoLabelOn        = True
  
  ;res@gsnCenterString  = "r(AO, air_zm) @Jan"
  ;res@gsnCenterStringFontHeightF = 0.03
  ;res@gsnCenterStringOrthogonalPosF = 0.05
   
  plot = gsn_csm_pres_hgt(wks,var(level|:,lat|:),res) 
  plot = ColorNegDashZeroPosContour(plot,"black","white","black")   
  overlay(base,plot)
  
  draw(base)                                                                 
  frame(wks)     
end
