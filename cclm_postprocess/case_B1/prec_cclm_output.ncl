;   10.19 绘制case A1 和 B1 的output

  ; 2020.09.26
  ; 检查降水数据，输出三日降水的总计数据
  ; 2020.09.25
  ; 移动到intel服务器上，并着手检验模式输出
  ; 2020.09.05
  ; 进行out01输出文件的测试
  ; 由于使用rotated coordinates 参考NCL官网示例脚本 
  ; https://www.ncl.ucar.edu/Applications/rotatedltln.shtml
  ; COSMO模型使用例
  ; http://www.ncl.ucar.edu/Applications/cosmo.shtml
  ; 另外有两个NCL-TALK查到的部分可以做参考（核心的东西是一致的）
  ; https://www.ncl.ucar.edu/Support/talk_archives/2009/0052.html
  ; https://www.ncl.ucar.edu/Support/talk_archives/2008/0970.html

  ; 关于transform资源的使用（关系到是不是native的网格）可以参考NCL官网给出的资源的使用例
  ; https://www.ncl.ucar.edu/Document/Graphics/Resources/tf.shtml
load "/m2data2/yycheng/playground/NCL-noob-s-practices/cclm_postprocess/case_B1/quantile.ncl"

begin
;;;>>>>>data reader
  file_path = "/m2data2/yycheng/data_stage/cptp/cptp_out/case_A1/cclm/merge/"
    file_name = "out02_merge_A1.nc" ; 读取进行合并之后的数据
  f_ordata = addfile(file_path + file_name, "r")

  p_ordata_A1 = f_ordata->$"TOT_PREC"$
  rlat = f_ordata->$"rlat"$
  rlon = f_ordata->$"rlon"$
  ;;; rotatead pole就存储在rotated_pole之中
  rotated_pole = f_ordata->$"rotated_pole"$
  pole = f_ordata->rotated_pole
  pole_lon = pole@grid_north_pole_longitude
  pole_lat = pole@grid_north_pole_latitude
  lat2d  = f_ordata->$"lat"$
  lon2d  = f_ordata->$"lon"$
  nlat  = dimsizes(lat2d(:,0))
  nlon  = dimsizes(lon2d(0,:))

  file_path = "/m2data2/yycheng/data_stage/cptp/cptp_out/case_B1/cclm/merge/"
    file_name = "out02_merge_B1.nc" ; 读取进行合并之后的数据
  f_ordata_B1 = addfile(file_path + file_name, "r")
  p_ordata_B1 = f_ordata->$"TOT_PREC"$
  ;;;>>>data checker

  ; printVarSummary(p_ordata_A1)
  ; printVarSummary(p_ordata_A1&time)
  ; print(or_time@units)
  or_time = p_ordata_A1&time
  ; set_time_start = 20070718
  ; set_time_end   = 20070723
  set_time_start = cd_inv_calendar(2008, 7, 19, 0, 0, 0, or_time@units, 0)
  set_time_end   = cd_inv_calendar(2008, 7, 24, 0, 0, 0, or_time@units, 0)
  ; print(set_time_start)
  plotdata_A1 = dim_sum_n(p_ordata_A1({set_time_start:set_time_end},:,:),0)
  plotdata_B1 = dim_sum_n(p_ordata_B1({set_time_start:set_time_end},:,:),0)
  printVarSummary(plotdata_A1)
  ; printMinMax(plotdata, 1)
  ; print(percent_to_value(plotdata,ispan(0, 100, 1)))
  ; plotdata_A1 = where(plotdata_A1.gt.350., 350, plotdata_A1)
  ; count numerical point storms
;   opt = True
;   opt@PrintStat = True
;   statb = stat_dispersion(plotdata_A1, opt)
  nps_A1 = plotdata_A1
  nps_A1 = 0.
;   percent_start = 99.0   
    do i=0.,1.,0.1
        percent = 99.0 + i  
        nps_A1_precent = percent_to_value(plotdata_B1,percent)
        print(percent + "% point value: "+nps_A1_precent)
        nps_A1 = where(plotdata_B1.gt.nps_A1_precent,i*10,nps_A1)
    end do
;;;>>>>>start plot
; PLOT = False
PLOT = True
if(PLOT) then
  print("-----start plot-----")
    ;---Start the graphics section
  wks  = gsn_open_wks("png", "./output_pic/totprec_B1")     ; send graphics to PNG file

  res                        = True             ; plot mods desired

  res@gsnMaximize            = True             ; maxmize plot in frame

  res@cnFillOn               = True             ; turn on color 
  res@cnLinesOn              = False            ; no contour lines
  res@cnLineLabelsOn         = False            ; no contour labels
  res@mpDataBaseVersion      = "MediumRes"      ; use finer database
  res@mpOutlineBoundarySets  = "National"

;---Turn on nicer tickmarks. 'conditional' prevents more than one tickmark object.
  res@pmTickMarkDisplayMode  = "conditional"

  res@gsnAddCyclic           = False
  res@gsnRightString         = ""

  res@cnFillPalette          = "perc2_9lev"
  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 360
  res@cnLevelSpacingF = 20 ;等值线间隔

;;;关键的参数设置 tfDoNCDOverlay(具体参考官网使用例) ，如果写入
;;;True  -> plotting the data natively
;;;False -> transform
;;;示例:
; res@tfDoNDCOverlay        = True
; res@tfDoNDCOverlay        = "NDCViewport"  ; NCL V6.5.0 or later
; res@tfDoNDCOverlay        = False      ; transform to standard lat/lon
; res@tfDoNDCOverlay        = "DataTransform"  

;;;>>>-----native plotting-----
  res_native = res

  ;---Zoom in on map

    ; Setting tfDoNDCOverlay to True ("NDCViewport") means you have specified
    ; the exact projection that your data is on, and thus no data
    ; transformation takes place when the contours are overlaid
    ; on the map.   

  res_native@tfDoNDCOverlay        = True
  ; res_native@tfDoNDCOverlay        = "NDCViewport"  ; NCL V6.5.0 or later

  res_native@mpLimitMode            = "Corners"
  res_native@mpLeftCornerLatF       = lat2d(0,0)   
  res_native@mpLeftCornerLonF       = lon2d(0,0) 
  res_native@mpRightCornerLatF      = lat2d(nlat-1,nlon-1)    
  res_native@mpRightCornerLonF      = lon2d(nlat-1,nlon-1)

  res_native@tiMainString           = "Native projection"
  res_native@pmTickMarkDisplayMode  = "always"

  res_native@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
  res_native@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

  res@tiMainString           = "Native rotated lat/lon Projection"

;;;>>> src plot
sres                 = res_native                                                        ; set up a second resource list               
;    sres@gsnDraw         = False                                                          ;         do not draw the plot               
;    sres@gsnFrame        = False                                                          ; do not advance the frame                    
   sres@cnLineLabelsOn  = False                                                          ; do not use line labels                     
   sres@cnLinesOn       = False                                                          ; do not draw contour lines                  
   sres@cnInfoLabelOn   = False                                                                                                        
   sres@cnFillOn        = True                                                  ; color fill                                   
   sres@cnSmoothingOn   = True
   sres@lbLabelBarOn= False                                                                                                            
   sres@cnLevelSelectionMode = "ExplicitLevels"                                                                                             
   sres@cnFillDrawOrder="postDraw"                                                                                                     
;    sres@cnLevels    = fspan(1,10,10)
   sres@cnLevels = (/0.999/)
;    print(fspan(0,10,11))                                                                                                
   sres@cnMonoFillPattern    = False            ; want multiple patterns                                                               
   sres@cnFillPatterns       = (/-1,17/)     ; the patterns                                                                        
   sres@cnMonoFillScale      = False            ; want different densities                                                            
   sres@cnFillScales         = (/1,1/)    ; change densities                                                                        
   sres@cnMonoFillColor      =True                                                                                                     
   sres@cnFillDotSizeF       = 0.0050

plot   = gsn_csm_contour_map(wks,plotdata_A1(:,:),res_native)    ; Draw plot
shade1 = gsn_csm_contour_map(wks,nps_A1,sres)
overlay(plot, shade1)
draw(plot)
end if

end